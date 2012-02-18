---
layout: post
title: "Continuous Integration: Rake, Albacore, TeamCity, Kiln, and NuGet"
date: 2012-02-18 07:22:14 -06:00
tags: "nuget teamcity rake albacore rake"
---
We started building a system at work. It's actually several UIs over a common domain and infrastructure, and includes refactoring and integrating a lot of legacy apps. We've split it up in to different solutions: Core & Infrastructure, Domain, Legacy, and UI.

###Rake & Albacore
Rake and albacore are an absolute joy to use. All the other .NET build tools I've tried ignore this one small fact: programmers code. Yes, it's Ruby. No, I won't be followig this up with a passive-agressive, dolphin-filled [@DHH](http://twitter.com/dhh) bromance post simultaneously denouncing and praising the .NET community.

You should absolutely give this a try today. I mean Rake, not the ".NET sucks. I'm leaving" post.

###TeamCity
Those JetBrans guys are pretty smart. TeamCity just gets it right. It's easy to set up. We're using a nightly build of TeamCity 7 so we can easily host the nuget packages we build. TeamCity checks out the code from Kiln, runs rake to update dependencies (nuget packages from our other solutions) and build the solution, then runs our tests and packages up our nugets. 

We have a minor issue where the TeamCity nuget feed sometimes has multiple versions of a package marked IsLatestVersion. This may be fixed already, but we haven't updated to a newer build. No one else has reported the issue.

###Kiln & Mercurial
IMO, Kiln is the GitHub of Mercurial (for commercial use, at least). The tight integration with FogBugz is nice. 

I like mercurial. I don't like mercurial as much as git. I believe the "git sucks on windows" argument is FUD. I haven't found a proper branching strategy I like on Mercurial, but I haven't spent much time looking either. Mercurial is noticably slower than git for getting a status and pushing commits.

###NuGet
In our continuous integration family, this is the ginger kid who ate one too many lead paint chips at grandma's house. I completly blew two sprints trying to hack around nuget issues.

The story goes like this:

1. Some dim bulb at apache decided that [log4net 1.2.11 needed to use different keys](http://logging.apache.org/log4net/release/faq.html#two-snks) for their assembly signing so anyone can patch it and sign it with the official key.
2. [Another dim bulb](http://nuget.org/profiles/cincura.net), perhaps at Apache, perhaps not, decided to publish [a log4net 1.2.11 package](http://nuget.org/packages/log4net) using the new key.
3. Even though it's compatible with log4net 1.2.11, the NServiceBus 3.0 package had to be locked down to log4net 1.2.10 only to [work around the signing issues](http://tech.groups.yahoo.com/group/nservicebus/message/12489). 

We have other packages that rely on log4net and don't have this restriction.

When a project updated to log4net 1.2.11, even accidentally, nuget pack used it as the minimum compatible version.

When that happened, we couldn't use NServiceBus and our package in the same project anymore, and we'd have to go fix the log4net version mess in the other solution, rebuild, and republish. This was almost never as simple as uninstalling the wrong version and reinstalling the right version.

NuGet allows you to use different versions of a package for different projects in the same solution. This is horribly, terribly, inexcusably wrong. One version per solution should be the default behavior, but it's not even an option. I don't know what the hell [@haacked](http://twitter.com/haacked) is thinking.

We kept spilling version soup all over our solutions - a stain that doesn't wash out easily.

I tried to work around this by using the -excludeVersions command line argument, but that wasn't available from the UI or powershell and broke more than it fixed.

Finally, we gave up. We set up a second non-TeamCity nuget server (actually, just a file share with .nupkg files) to host exactly one version of each external package we use. I don't like this. It has the same bitter taste as nanny-state firewall rules.

A few good things came out of all this:

* My build script is capital-a Awesome&trade;
* I have disturbingly intimate knowledge of csproj files and their relation to packages.config.
* I can hack together a rake script in seconds with Ruby only a mother could love.