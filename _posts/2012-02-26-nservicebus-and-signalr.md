---
layout: post
title: NServiceBus and SignalR
date: 2012-02-26 14:34:49 -06:00
tags: "NServiceBus SignalR"
excerpt: "I started thinking about how I could build a responsive, postback-free user experience in an application with a rich business layer or even a collaborative domain without drowning in AJAX."
---
###The Inspiration
[Dario Quintana](https://twitter.com/#!/darioquintana) shared [this](http://www.asp.net/single-page-application/an-introduction-to-spa/overview/landingpage) on Twitter. The Single Page Application is something new in ASP.NET MVC 4. As near as I can tell, it's an HTML and javascript front-end tied to an Entity Framework back end. I haven't looked at the code, so I'll withhold judgement.

I started thinking about how I could build a responsive, postback-free user experience in an application with a rich business layer or even a [collaborative domain](http://www.udidahan.com/2011/10/02/why-you-should-be-using-cqrs-almost-everywhere%E2%80%A6/) without drowning in AJAX.

###NServiceBus messaging architecture
I ripped off this architecture from smart people&trade; like Udi Dahan and Greg Young. I have no doubt they would say I'm doing it completely wrong.

Let's say we have a single bounded context / service / autonomous bounded context / whatever, and it uses a standard command and event system to communicate between the UI and the domain - something like this\:
![Commands and Events Diagram](/images/commands-and-events.png)

Of course, NServiceBus lets us send commands reliably from the web application to the domain, and then publish the resulting events from the domain to any subscribed event handlers.

###SignalR
SignalR hubs are magical. This is the first framework I've seen that lets us seamlessly call browser javascript methods from the server. 

In the server:
<script src="https://gist.github.com/1911998.js?file=SignalRServerToClient.cs">
</script>

In the browser:

<script src="https://gist.github.com/1911998.js?file=SignalRServerToClient.js">
</script>

This updates the stats on every browser with a connection to that hub.

If that weren't enough, we can also call methods on the server, written in C#, from javascript running in the browser. All of the plumbing is handled for you.

In the browser:
<script src="https://gist.github.com/1911998.js?file=SignalRClientToServer.js">
</script>

In the server:
<script src="https://gist.github.com/1911998.js?file=SignalRClientToServer.cs">
</script>	
###A growling web application
It's not hard to imagine a rich browser application where the web server is mostly serving static files and SignalR hub connections.

Let's say we want to take our messaging architecture and wire it up to build a Growl-type notification system. We can add an extra set of event handlers, this time inside our web application, to push those events through SignalR hubs down to the browsers, where they pop up notifications for events each user cares about.

Here's an example\: You're visiting an auction website. You've placed a bid on an item. As you browse the site for other items, wouldn't it be nice to know when you've been outbid?

The server-side might look something like this\:
<script src="https://gist.github.com/1911998.js?file=AuctionHub.cs">
</script>

SignalR lets us put clients in to groups. When a customer bids on an item, we add them to the group for that item. We use `Clients[message.ItemId]` to reference the group of clients interested in this particular item. We tell all of their browsers to call the `auctionHub.onBidAccepted` method, and pass the item id, the item name, and the new highest bid.

Using Pines Notify, the client-side code might look something like this\:
<script src="https://gist.github.com/1911998.js?file=AuctionGrowl.js">
</script>

###Imagine the possibilities
This is just a quick and dirty example. What if you pushed events down to a javascript MVVM framework like KnockoutJS to keep pages updated in real time? Building real, responsive thick-client apps in a browser isn't difficult.