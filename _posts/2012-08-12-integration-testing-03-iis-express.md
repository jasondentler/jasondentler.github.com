---
layout: post
title: "Integration Testing: IIS Express"
date: 2012-08-12 09:16
series: "Integration Testing"
tags: [IIS Express]
excerpt: "In [the previous post,](../integration-testing-ravendb/) I showed you how we control RavenDB from our test framework. In this post, we'll set up IIS Express in much the same way."
---
In [the previous post,](../integration-testing-ravendb/) I showed you how we control RavenDB from our test framework. In this post, we'll set up IIS Express in much the same way.

###Everyone's favorite web server, Express edition
IIS 7.5 is the best version of IIS so far. Unfortunately, from an automated testing perspective, it's a large, clumsy beast, requiring administrator privileges for nearly everything. 

Thankfully, we also have the option to use IIS Express. It's nimble and easy to automate. Most importantly, it's the same server core, so if it works here, it'll work on the full version.

###Location, location, location
The first parameter we have to feed to IIS Express is the filesystem path to our website. For this example, I just point this to my web project folder. With a CI build system, you can build & publish your website to a folder, then let IIS Express host it from there. 

The path argument looks like this:
`/path:"C:\Projects\SpecFlowSeleniumTraining\src\UI"`

###Port
We could let IIS Express auto-assign a port, but since we already have the code to pick a random available port, I'd rather pick it myself.
<script src="https://gist.github.com/3319958.js?file=GetRandomUnusedPort.cs">
</script>

The port argument looks like this:
`/port:455086`

###Find the path
The default location for IIS Express is `C:\Program Files (x86)\IIS Express\iisexpress.exe`. We also let this be overridden by the app.config.

###All together now
When we put it all together, the command line looks like this:

      C:\Program Files (x86)\IIS Express\iisexpress.exe 
      /path:"C:\Projects\SpecFlowSeleniumTraining\src\UI" 
      /port:455086

###Head for the exit
Just like with RavenDB, we can press `Q` to quit IIS Express. Unfortunately, it doesn't read that `Q` from standard input. I suspect it watches for WM_KEYDOWN messages or something like that. Our only option is to `.Kill()` the process.

<a href="https://github.com/jasondentler/SpecFlowSeleniumTraining
"><img style="position: absolute; top: 0; right: 0; border: 0;z-index:100" src="https://s3.amazonaws.com/github/ribbons/forkme_right_darkblue_121621.png" alt="Fork me on GitHub"></a>