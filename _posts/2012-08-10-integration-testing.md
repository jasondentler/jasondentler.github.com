---
layout: post
title: "Integration Testing"
date: 2012-08-10 18:36
tags: ["ASP.NET MVC","SpecFlow","Selenium","RavenDB"]
---
###Why?
I'm teaching next week. The subject is how we'll write integration tests for our new ASP.NET MVC public dot com website. Since I'm going through the effort to organize my thoughts, I might as well publish it for everyone - Hanselman's limited lifetime keystrokes theorem and all.
###What?
Ideally, we want to automatically drive the three major desktop browsers through every user story of our website, checking for a few key things:

 * Each page works for the expected states.
 * The javascript behaves on all the major browsers.
 * The new stuff we write doesn't break the stuff we already wrote.
 
We're not checking that the pages are rendered properly. That's still entirely manual. 
 
###How?
Our website runs on a strict diet of IIS 7, [ASP.NET MVC](http://www.asp.net/mvc) 3, and [RavenDB](http://ravendb.net/). We need to create this infrastructure in a sterile environment for each test. Our scenarios are written in [SpecFlow](http://www.specflow.org)-flavored Gherkin. We'll use [Selenium](http://seleniumhq.org/) for driving the browser. 

##Spec Flow
Here's an example Spec Flow feature file:
<script src="https://gist.github.com/3319624.js?file=DisplayWidgets.feature">
</script>

###Where to put infrastructure setup and teardown

When testing systems or large parts of systems, you have to prepare the infrastructure for the test. With Spec Flow, it's not obvious how to do that. We'll create a separate class for our web configuration.

<script src="https://gist.github.com/3319624.js?file=WebConfiguration.cs">
</script>

Just like every other class containing Spec Flow stuff, we need to decorate this one with the `[Bindings]` attribute.

The `BeforeTestRun` and `AfterTestRun` methods are run before the first test and after the last test, respectively. These methods must be `static`. The magic is in the attributes, not the method name.

Spec Flow also provides `[BeforeFeature]` and `[AfterFeature]` to run code just before the first scenario of each feature file and just after the last scenario of each feature file. You can limit it to features with specific tags. So far, I haven't found a use for this, but it's nice to know it exists.

Finally, we can run code before and after each scenario with `[BeforeScenario]` and `[AfterScenario]`. This can be limited to scenarios with a specific tag. In the example above, we only run the methods when the scenario is tagged with `@web`.

####Here's our set up:
The entire test suite is run 3 times, once for each browser. Our CI build script will automate this and poke the browser value in to the app.config each time.

#####IIS Express 7.5
IIS Express 7.5 starts up before each scenario and gets killed after. It's possible to put it in `BeforeTestRun`, but for my solution, it would sometimes hang randomly between tests. I couldn't reproduce the problem outside the automated tests.

#####RavenDB
We start up a fresh in-memory RavenDB instance before each test. Because we run in-memory, this is especially fast to set up and tear down.

It could be even faster if we used RavenDB's reset command between tests instead of killing and relaunching the process. RavenDB tries to clear the console window, which throws a "Handle is invalid" exception with Console.Out redirected to our test runner.

#####Browser
The browser also starts up fresh before each test.

Before each test, we clear all the cookies.

**Warning:** The browser cache is a potential source of cross-contamination between scenarios. With the right settings, restarting Firefox between tests will do this. I haven't found a solution for Chrome. For Internet Explorer, we can run this:
<script src="https://gist.github.com/3319624.js?file=ClearIECache.cs"></script>

After each test, we check for test errors. If the test failed, we save an image of page as well as the HTML.

###What's next?
In the next part of this series, we dive in to the specifics of controlling RavenDB.

*None of this should be considered original work. This solution is cobbled together from bits and pieces I found scattered across the web.*