---
title: "Introducing Tenter"
layout: post
date: 2019-07-08 18:54:19 +0900
excerpt: "An introduction to the Tenter gem."
category: 
tags: 
---

I pushed out a gem over the weekend called [Tenter][gh-t]. You might be interested in it.

[gh-t]: https://github.com/pyrmont/tenter

## What is Tenter?

Tenter is a Sinatra-based web application that runs user-defined commands in response to HTTP requests. It provides a simple way of creating webhooks that can be called by GitHub in response to events in a repository.

A 'webhook' is a URL that [you can configure][gh-help] GitHub to send a request to when certain events happen in your repository. Receiving a pushed commit is an example of an 'event'.

[gh-help]: https://help.github.com/en/articles/about-webhooks

## Why Does Tenter Exist?

Tenter is meant as an alternative to deployment systems like Capistrano. Those have their place but are ridiculously heavy if all you want to do is have your server perform an action after you do something with a repository.

The source files for this blog are all in [a GitHub repo][gh-repo], for example. With Tenter, I can cause the server that hosts my blog to update its copy of the repo and rebuild itself whenever I push a change to GitHub.

[gh-repo]: https://github.com/pyrmont/articles.inqk.net

## How Does Tenter Work?

Tenter expects to receive HTTP requests to URLs of the form `/run/<cmd>/in/<dir>`. When it receives such a request, it first authenticates it. Tenter does this by looking up the secret in `/var/www/<dir>/hooks.yaml` and checking whether the signature in the `X-Hub-Signature` header has been validly created using the secret (GitHub generates this header automatically).

If the signature is valid, Tenter spawns a separate process to execute the file `<cmd>` in the `/var/www/<dir>/commands/` directory and responds that the command has been initiated.[^1]

If the signature isn't valid, or if `<cmd>` or `<dir>` don't exist, Tenter returns an error.

### Is Tenter Configurable?

Tenter takes a convention over configuration approach. Out of the box, it will assume the directories it is watching are in `/var/www/`, that each directory's secret is in `hooks.yaml`, that commands are in `commands/` and so on.

The defaults are meant to cover most use cases but if you want to tweak things the defaults are all configurable. More information on this is available in [the README][README].

[README]: https://github.com/pyrmont/tenter/blob/master/README.md

### Getting It

Tenter is available as [a gem][rg-t] from RubyGems. I hope you find it useful!

[rg-t]: https://rubygems.org/gems/tenter

[^1]: Tenter detaches the process after spawning. In other words, Tenter does not wait for the result of the command and does not guarantee successful execution. By default, Tenter logs the output of commands to `/var/www/<dir>/log/commands.log`.