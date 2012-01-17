---
layout: post
title: "SQL to Simple.Data"
date: 2012-01-16 19:44
excerpt: "I like Simple.Data, but I waste a lot of time translating from the SQL in my head to Simple.Data, particularly when my queries get a little weird. No more!"
---
I like Simple.Data, but I waste a lot of time translating from the SQL in my head to Simple.Data, particularly when my queries get a little weird. No more! Mark Rendle gave me a tip to bypass the query side of Simple.Data while still using the part I really like: the dynamic results. 

Each query can return 3 possible results:

 * Multiple result sets
 * Multiple rows
 * A single row

Of course, if you just want a scalar value, use command.ExecuteScalar(). 

Here's the trick. Simple.Data.Ado includes extension methods on data readers to convert the data in to dictionaries, and SimpleRecord (the "dynamic" that represents a row in Simple.Data) has a constructor that accepts a dictionary.

####Using it

Let's say you want to query a page and count of Albums and Artists from the Chinook database. It might look something like this:

<script src="https://gist.github.com/1626280.js?file=Program.cs">
</script>

####Read from a data reader

<script src="https://gist.github.com/1626280.js?file=DataReaderExtensions.cs">
</script>

####The rest

Grab the rest of the code from [this gist](https://gist.github.com/1626280)
