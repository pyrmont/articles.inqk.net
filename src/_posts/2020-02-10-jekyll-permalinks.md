---
title: "How-To: Custom Placeholders in Jekyll Permalinks"
layout: post
date: 2020-02-10 14:08:15 +0900
excerpt: "Instructions on how to write custom placeholders for Jekyll permalinks."
category: 
tags: 
---

Jekyll provides a fixed set of placeholders that can be used in permalinks. Here's how to make new ones.

## Background

I recently set up a microblog using Jekyll. One problem I had was in deciding on the permalink scheme.

My first attempt was to combine the year, month, day, hour, minute and second of each post into a single number. A post that was made on 10 February 2020 at precisely 10:00 am would have the permalink `/post/20200210100000.html`. That seemed like a good choice until I noticed I'd set the time zone of my Jekyll installation incorrectly, updated it and then broke the URL of every single post.

What I wanted was to use the number of seconds since the beginning of the Unix epoch, sometimes referred to as [Unix time][wk-ut].[^1] The problem is that Jekyll, the software I use to create my microblog, doesn't provide a Unix time placeholder ([here's the list][ph-list]).

[wk-ut]: https://en.wikipedia.org/wiki/Unix_time "Read the article 'Unix time' on Wikipedia"

[ph-list]: https://jekyllrb.com/docs/permalinks#placeholders "See the full list of Jekyll placeholders"

A lesser[^2] man might have stopped at this impasse. Not I. A quick consultation of Jekyll's source reveal that the way that it supports placeholders is by using them to access instance methods of the `Jekyll::Drops::Drop` class. Well, that's an easy fix. Jekyll is written in Ruby and one of the great[^3] things about Ruby is the ability to reopen classes at any point and just chuck some new methods in there. Jekyll loads Ruby files in your `_plugins` directory at startup so let's write a very simple plugin.

## Steps

### Step 1. Create a plugins directory

There are different ways to get Jekyll to load a plugin. The simplest way is to create a `_plugins` directory at the root of your site's source directory (if you don't already have one).

```console
$ mkdir _plugins
```

### Step 2. Create the plugin file

In your editor of choice, save the following in your plugins directory:

```ruby
module Jekyll
  module Drops
    class UrlDrop < Drop
      def epoch
        @obj.date.strftime("%s")
      end
    end
  end
end
```

Since Jekyll loads all the Ruby files in `_plugins`, name it whatever you want.
I went with `jekyll_epoch_permalinks.rb`.

### Step 3. Update your Jekyll configuration

The final thing to do is update your permalink structure. Here's mine:

```yaml
permalink: "/post/:epoch.html"
```

## Wrap-Up

That's it; you're done!

[^1]: This idea was shamelessly stolen from [Paul Robert Lloyd][prl].

[prl]: https://paulrobertlloyd.com/ "Visit Paul's website"

[^2]: Wiser.

[^3]: Terrible.