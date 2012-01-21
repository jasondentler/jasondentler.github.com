---
layout: post
title: "New and improved Simple.Data.RawSql package released"
date: 2012-01-21 10:30
tags: Simple.Data
excerpt: "Today, I published my first nuget package, Simple.Data.RawSql, a set of extensions to Simple.Data for raw sql queries."
---
Today, I published my first nuget package, [Simple.Data.RawSql](https://github.com/jasondentler/Simple.Data.RawSql), a set of extensions to [Simple.Data](https://github.com/markrendle/Simple.Data) for raw sql queries. It includes some syntax improvements over the code from my [previous post](http://jasondentler.com/blog/2012/01/sql-to-simple-dot-data/).

Here's a few examples. First up, querying a single row:

<script src="https://gist.github.com/1653230.js?file=singlerow.cs">
</script>

Notice that specify the type for the `db` variable. `Database.Open` returns `dynamic`. If we left it as `dynamic` (or used `var` since `Open` returns `dynamic`), we couldn't call our `ToRow` extension method.

To query several rows:

<script src="https://gist.github.com/1653230.js?file=rows.cs">
</script>

Finally, you may want to batch several queries together and return multiple result sets:

<script src="https://gist.github.com/1653230.js?file=resultsets.cs">
</script>

