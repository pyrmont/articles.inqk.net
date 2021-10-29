---
title: "Development Dependencies in Janet"
layout: post
date: 2021-10-29 09:25:57 +0900
excerpt: "Avoiding the automatic installation of Janet dependencies that are only necessary for development."
category: 
tags: 
---

Janet's package manager, JPM, can be used to install the dependencies of a Janet project that are specified in `project.janet` under the `:dependencies` key. If the dependency itself has dependencies, JPM will install these as part of the installation process. That's conceptually simple but it means that if you need dependencies for the development of your project (e.g. a testing library like my [Testament][]), these will be installed for all consumers of your project. That seems like a waste.

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
  :dev-dependencies ["https://github.com/janet-lang/spork"
                     "https://github.com/pyrmont/testament"])

(declare-source
  :source ["src/argy-bargy.janet"])

# Development

(def project-meta (dyn :project))

(task "dev-deps" []
  (if-let [deps (project-meta :dev-dependencies)]
    (each dep deps
      (bundle-install dep))
    (do (print "no dependencies found") (flush))))
```

This solution has two components.

First, we can add whatever keys we want to the `declare-project` call so let's create a key `:dev-dependencies` and add a tuple of URLs just like we would with `:dependencies`.

Second, we'll create a task that we can run to install these dependencies. Unfortunately, at the time of writing, we can't access the values defined in `define-project` (I filed [an issue][issue] about this) so we need to create a `project-meta` binding that's accessible from our task's environment. Then we basically do the same thing that JPM does when we run `jpm deps`.

[issue]: https://github.com/janet-lang/jpm/issues/34 "See issue #34 in the janet-lang/jpm repository on GitHub"

Finally, eagle-eyed readers will notice that my `project.janet` file has one additional task:

```janet
(task "netrepl" []
  (with-dyns [:pretty-format "%.20M"]
   (import spork/netrepl)
   (eval ~(netrepl/server "127.0.0.1" "9365"))))
```

This creates a `netrepl` task we can use to start a netrepl server. Why is `eval` in there? The problem is that the binding `netrepl/server` depends on the Spork library being in the `project.janet` environment. However, since we're not importing it, we have a problem. My solution is to quasi-quote the function call and then evaluate the result at runtime.