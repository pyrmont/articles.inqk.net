---
title: "What is tools.deps?"
layout: post
date: 2019-08-13 17:16:30 +0900
excerpt: "An explanation of Clojure's tools.deps library."
category: 
tags: 
---

The _Functional Design in Clojure_ podcast had [a recent episode][fdc] where the hosts, Christoph and Nate, discussed different build tools for Clojure projects. There are currently three main options for Clojurists: [Leinengen][lein],[^1] [Boot][boot] and tools.deps.[^2]

[fdc]: https://clojuredesign.club/episode/040-should-i-use-lein-boot-or-tools-deps/ "The page for Episode 40 of the 'Functional Design in Clojure' podcast"

[lein]: https://leiningen.org/ "The homepage of the Leinengen project"

[boot]: https://boot-clj.com/ "The homepage of the Boot project"

When I started using Clojure in December of last year, I remember being really confused about what tools.deps _was_ and what it could and couldn't do. People talked about it in comparison to Leinengen and Boot but it didn't seem to work like those projects did. Worse still, it wasn't clear if it was separate to this thing called 'deps.edn' that sometimes seemed to refer to the same thing but sometimes seemed to mean something else.

Christoph and Nate didn't have time to go into an extended explanation of tools.deps on the show and so I thought it might be helpful to write down the understanding I eventually reached in case it can benefit others. Let's get to it!

## tools.deps is a Library

tools.deps is a library that comes _with_ Clojure. It was introduced with Clojure 1.9. If you have a version of Clojure since 1.9, tools.deps is just there. This makes it different to both Leinengen and Boot which require separate installations.

This leads to one of the things I found difficult to grok at first. How do you _use_ tools.deps? The trick is that you don't. At least not directly. In most cases, you use Clojure's command line utilities, `clojure` and `clj`. _These_ utilities will look for a special configuration file and use the information in this file, together with the functions in the tools.deps library, to resolve your dependencies, download any files necessary and generate the classpath that Clojure passes to Java to make everything work.

## tools.deps is Not a Build Tool

Leinengen and Boot are build tools. In addition to managing dependencies for a project, they can do things like build a JAR file for your project. tools.deps is intentionally more limited.

In the aforementioned _Functional Design in Clojure_ episode, Christoph and Nate explain that, while tools.deps by itself isn't a build tool, it can be used by other projects to create build tools. It has taken time for the community to produce these kinds of projects[^3] but, as they have, the necessity of using Leinengen and Boot has been reduced. One would expect that to continue.

## tools.deps Doesn't Exist (Yet)

Another point of confusion is the fact that there isn't actually a library called tools.deps. At least there isn't at the time of writing. The current approach of the Clojure developers is to add words like 'alpha' to the name of a library while it's in development. Although the library will eventually be called tools.deps, it's currently [tools.deps.alpha][tda].

[tda]: https://github.com/clojure/tools.deps.alpha "The GitHub repository for tools.deps.alpha"

While we're on the topic of names, you may be wondering why it's called tools.deps at all. Why not deps-alpha? Or clojure.deps? Or something else entirely?

There's really no technical reason. It's a convention in Clojure that namespaces consist of at least two segments (i.e. `first.second`). For most libraries, the first segment is the name of the library, with the second segment being used to encapsulate a particular aspect of that library.

That's not the approach taken for the 'official' Clojure libraries, however. For those libraries, the library itself is usually part of a broader project (e.g. tools). That broader project is the name of the first segment of the namespace with the name of the particular library forming the second segment. Additional segments can be added from there (as is the case with tools.deps.alpha).

Notwithstanding the fact there isn't actually a tools.deps library at present, I'll refer to the library as tools.deps for the remainder of this post to be consistent with conventional usage in the Clojure community.

## tools.deps and `deps.edn`

tools.deps is an ordinary Clojure library with ordinary Clojure functions you could call from your own ordinary Clojure code. But as explained above, its typical use is via the `clojure` and `clj` command line utilities. The way then that most people 'use' it is by specifying the configuration file that Clojure looks for by default: `deps.edn`.

Now in contrast to the name of the library, `deps.edn` is not a two-segment namespace. It's a file with the basename `deps` and the file extension `.edn`. `.edn` is the file extension used for files written in the [edn format][edn].[^4] edn was developed by the same people that developed Clojure and is its preferred human-readable data format. It's overly reductive but you can think of edn being to Clojure what JSON is to JavaScript.

[edn]: http://edn-format.org/ "The homepage for edn"

The fact that most interaction with tools.deps is through `deps.edn` is the reason the names are sometimes used as synonyms for each other. But `deps.edn` is really the name of the configuration file. It's expected to be in the root of your project and is a map[^5] that has three keys: (1) `:paths`, (2) `:deps` and (3) `aliases`. An example `deps.edn` file looks like this:

```clojure
{:paths ["src"]
 :deps {}
 :aliases
 {:1.7 {:override-deps {org.clojure/clojure {:mvn/version "1.7.0"}}}
  :bench {:extra-deps {criterium/criterium {:mvn/version "0.4.4"}}}
  :test {:extra-paths ["test"]}}}
```

These keys are hopefully not too obtuse. They are used to tell `clojure` and `clj` where your project's Clojure code is (in this case, a directory called `src/`), what dependencies your project has (in this case zero, represented by the empty map `{}`) and a collection of aliases that you can use with `clojure` and `clj`. The `1.7` alias, for example, overrides the current version of Clojure installed so that your project is run with version 1.7 of Clojure. As [the official guide][guide] explains, you could execute a command that uses all these aliases like so:

[guide]: https://clojure.org/reference/deps_and_cli "The page 'Deps and CLI' on the official Clojure website"

```sh
clj -A:1.7:bench:test
``` 

## tools.deps Advantages

The final question you might be wondering is: if tools.deps is more limited than Leinengen and Boot, why use it?

tools.deps has a couple of advantages:

1. **Faster Start Up Times**
   Clojure has a reputation (not undeserved) for being slow to start up. While some of this is the inevitable consequence of running on the Java Virtual Machine, some of it is because it's typically run via tools like Leinengen and Boot that impose additional start up costs of their own. By making a library that just handles dependencies and combining that with the `clojure` and `clj` utilities, users can enjoy (slightly) faster start up times.

2. **Wider Variety of Dependencies**
   Leinengen and Boot are built with a conception of dependencies being packaged up as JAR files and made available from a repository like Maven or Clojars. That's very often the case but it's not always true. tools.deps has a far broader conception, allowing dependencies to be specified by coordinates that refer to the local file system or specific commits in Git repos.

3. **Abstract-Feeling-of-Satisfaction-From-Doing-Something-the-Quote-Unquote-Right-Way**[^6]
   Clojure very much embraces the Unix tools philosophy of simple tools that are designed for a specific purpose. If you're the type of person who likes ideological consistency, using tools.deps should make you feel warm and fuzzy inside. Also it's probably easier to test or something.

## Conclusion

If you were confused about tools.deps, hopefully that's helped clear things up. If I've made a mistake somewhere, please don't hesitate to let me know!

[^1]: Leinengen is often abbreviated to 'lein', the name of its command line program. To avoid any ambiguity in this post, I'll stick to calling it Leinengen.

[^2]: As discussed below, tools.deps isn't actually a build tool but since it replaces certain uses of Leinengen and Boot (which are build tools), it's typically thrown into comparisons with them.

[^3]: An example given in the episode is JUXT's [Pack][pack] utility.

[pack]: https://github.com/juxt/pack.alpha "The GitHub repository for JUXT's Pack"

[^4]: While always written in lowercase (no doubt to prevent is being mispronounced 'eee-dee-enn'), edn is actually an acronym. It stands for extensible data notation and is a human-readable data format. It's pronounced like 'eden'.

[^5]: Clojure's 'maps' are key-value data structures. In other languages they might be called 'hashes', 'objects', 'dictionaries' or 'associative array'.

[^6]: I assume there is a German word for this.