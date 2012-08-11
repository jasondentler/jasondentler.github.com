---
layout: post
title: "Integration Testing part 1"
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
The test suite is run 3 times, once for each browser. 

#####IIS Express 7.5
IIS Express 7.5 starts up before the first test and gets killed after the last test. The application follows along. 
*Warning: If you use static or application-scoped objects, there is some potential for cross-contamination here.*

#####RavenDB
We start up a fresh in-memory RavenDB server before each scenario, and stop it after each scenario. This cuts out most of the risk of cross-contamination of the tests while still being fast as hell. 

#####Browser
The browser also starts up before the first test and closes after the last test. 

Before each test, we browse to about:blank, close any pop up windows, and clear all the cookies. *Warning: I haven't found a way to programmatically clear the browser cache or history. This is another potential source of cross-contamination.*

After each test, we check for test errors. If the test failed, we save an image of page as well as the HTML.


