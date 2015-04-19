---
layout: post
title: NHibernate and TransactionScope and Web API
date: 2015-04-18 21:00:00 -06:00
tags: "NHibernate TransactionScope WebApi"
excerpt: "I have a Web API project that uses NHibernate and NServiceBus, and I need them to succeed or fail together, within a business transaction."
---
###The problem
I have a Web API project that uses NHibernate and NServiceBus, and I need them to succeed or fail together, within a business transaction. There is exactly one transaction per web request.

###What I tried
To enlist in and coordinate the distributed transaction, I need to wrap each web request in a `TransactionScope`. I set up an `ActionFilter`.

Inside the transaction scope, I need to set up the standard NHibernate session-per-request unit of work. I set up another `ActionFilter`.

#####Action Filter order
[Action filters don't get executed in a specific order.](http://stackoverflow.com/questions/21628467/order-of-execution-with-multiple-filters-in-web-api) I couldn't ensure the transaction scope would be opened before the NHibernate session. A slightly modified version of [this](http://stackoverflow.com/questions/21628467/order-of-execution-with-multiple-filters-in-web-api) ordered filter provider worked.

#####Per request
I'm using [StructureMap nested containers](http://structuremap.github.io/the-container/nested-containers/) to ensure everything gets cleaned up at the end of each request, even if the filter gets jacked up. This matches up really well with the Web API concept of [dependency scopes / dependency resolver](http://www.asp.net/web-api/overview/advanced/dependency-injection).

#####Lazy loading
I'm using NHibernate lazy loading and LINQ deferred execution in a few responses. I don't have to do it that way, but it was already written, and I'd rather just make it work. The issue is that when the response is serialized, the LINQ query is executed, which triggers lazy loading. [By the time this happens](http://www.asp.net/media/4071077/aspnet-web-api-poster.pdf), my filter's `OnActionExecuted` has already run. The NHibernate session is already closed.

The solution was to use a message handler instead of filters.

###The (partial) solution
<script src="https://gist.github.com/jasondentler/b9ea3d83586102eb9a67.js?file=UnitOfWorkHandler.cs">
</script>

We pass in the factory delegates to make the handler testable.

#####Can't detect ambient transaction
The standard way to detect an ambient transaction didn't work for me. `Transaction.Current` was always `null`. I suspect an issue flowing it across async / await. For now, every request gets a transaction, whether it needs it or not.
<script src="https://gist.github.com/jasondentler/b9ea3d83586102eb9a67.js?file=ambient%20transaction.cs"></script>

#####Still lazy loading issues
So far, this works flawlessly when the controller actions return something other than `void`, `HttpResponseMessage` or an `IHttpActionResult`. Check out the Result Conversions box in the lower right corner of the [ASP.NET Web API 2 lifecycle poster](http://www.asp.net/media/4071077/aspnet-web-api-poster.pdf) to understand why. 

If I need more control over the responses, we have to return either `HttpResponseMessage` or `IHttpActionResult`. Now the service can return more intelligent responses like custom 404 messages, descriptive 409 conflict responses, 302 redirects, etc. The drawback is that these responses aren't serialized at the same point in the request lifecycle. In fact, they aren't serialized inside the Web API stack at all. It's left up to the host. 

This means our lazy loading issue continues. To fix it once and for all, we need to serialize the response content before the NHibernate session gets closed. The simplest solution I could come up with required a second message handler.
<script src="https://gist.github.com/jasondentler/b9ea3d83586102eb9a67.js?file=SerializationHandler.cs"></script>

#####Wiring it up
Here's how to wire up these two new message handlers.
<script src="https://gist.github.com/jasondentler/b9ea3d83586102eb9a67.js?file=Global.asax.cs"></script>

