---
title: "Development Dependencies in Janet"
layout: post
date: 2021-10-29 09:25:57 +0900
excerpt: "Avoiding the automatic installation of Janet dependencies that are only necessary for development."
category: 
tags: 
---

Janet's package manager, JPM, can be used to install the dependencies of a Janet project that are specified in `project.janet` under the `:dependencies` key. If the dependency itself has dependencies, JPM will install these as part of the installation process. That's conceptually simple but it means that if you need dependencies for the development of your project (e.g. a testing library like [Testament][]), these will be installed for all consumers of your project. That seems like a waste.

[Testament]: https://github.com/pyrmont/testament "The GitHub repository for the Testament library"

Other dependency managers like Ruby's Bundler or Node's NPM avoid this problem by providing a means to identify a dependency as being for development. In my latest Janet library, [Argy-Bargy][], I tried to see if I could do something similar. Here's what I came up with:

[Argy-Bargy]: https://github.com/pyrmont/argy-bargy "The GitHub repository for the Argy-Bargy library"

```janet
(declare-project
  :name "Argy-Bargy"
  :description "A fancy command-line argument parser for Janet"
  :author "Michael Camilleri"
  :license "MIT"
  :url "https://github.com/pyrmont/argy-bargy"
  :repo "git+https://github.com/pyrmont/argy-bargy"
  :dependencies []
  :dev-dependencies ["https://github.com/pyrmont/testament"])

(declare-source
  :source ["src/argy-bargy.janet"])

(task "dev-deps" []
  (if-let [deps ((dyn :project) :dev-dependencies)]
    (each dep deps
      (bundle-install dep))
    (do
      (print "no dependencies found")
      (flush))))
```

This solution has two components.

First, we can add whatever keys we want to the `declare-project` call so let's create a key `:dev-dependencies` and add a tuple of URLs just like we would with `:dependencies`.

Second, we'll create a task that we can run to install these dependencies. I've called this task `dev-deps`. The task pulls the tuple out of the project metadata and then basically does the same thing that JPM does when we run `jpm deps`. Now we can run this task by typing `jpm run dev-deps` at the command line.