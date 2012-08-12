---
layout: post
title: "Integration Testing: RavenDB"
date: 2012-08-11 9:48
tags: ["ASP.NET MVC","SpecFlow","RavenDB"]
---
In [the previous post,](../integration-testing/) I introduced the technology we'll be using to test our new website:

* IIS Express 7.5
* ASP.NET MVC 3
* RavenDB
* SpecFlow
* Selenium

In this part, I'll show you how we control  RavenDB.

###Raven DB command line
We want to start up a fresh in-memory RavenDB server before each test. Lucky for us, RavenDB provides every option under the sun right on the command line. Specifically, we want to use the `/ram` command line argument to run RavenDB in memory only. 

It's also important that we know which port RavenDB is using so we can connect to it. We can specify this on the command line with `--set=Raven/Port==`[port number]

Opening a TcpListener on port 0 actually gets a random available port from the OS. So, to find an available port, we run this code:
<script src="https://gist.github.com/3319958.js?file=GetRandomUnusedPort.cs"></script>

The command line would be:
`RavenDB.Server /ram --set=Raven/Port=={unused port from code above}`

Then, we build a connection string using the same port number and poke it in to the web.config.

###Finding your own path
How can we find Raven.Server.exe? It would be pretty easy to set it in the app.config. It would also be pretty lame, especially if you're working on a team. While it's safe to assume your coworkers have RavenDB installed, they won't all have it installed in the same place.

It's likely installed as a windows service, so let's just look up the directory where the service goes to find it. That information is stored in the registry, in the `HKLM\System\CurrentControlSet\Services\RavenDB` key, in the `ImagePath` variable. We can get to it like this:
<script src="https://gist.github.com/3319958.js?file=GetRavenDbServicePath,cs">
</script>

###The magic
Now that we have the full path to the executable and our arguments all figured out, we can run RavenDB.

<script src="https://gist.github.com/3319958.js?file=StartRaven.cs"></script>

Finally, to stop raven, we have this code:
<script src="https://gist.github.com/3319958.js?file=StopRaven.cs"></script>
