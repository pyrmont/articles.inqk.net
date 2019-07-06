---
title: "Introducing the simple-layout Leiningen Template"
layout: post
date: 2019-01-24 18:58:32 +0900
excerpt: "An introduction to a Leiningen template that creates a very simple project."
category: 
tags: 
---

I've made a template for Leiningen called [simple-layout][gh-sl] (my first project on [Clojars][cj-sl]!). The template creates three files: `.gitignore`, `project.clj` and `<project-name>.clj`.

[gh-sl]: https://github.com/pyrmont/lein-simple-layout

[cj-sl]: https://clojars.org/simple-layout/lein-template

The project file is extremely minimal and does little more than set the version of Clojure to use as a dependency. At the time of writing, that defaults to 1.10.0 but you can specify the version by passing a template argument.

Here's how you'd create a project called `exercises`, set it to use Clojure 1.6.0 and create the files in the directory `chapter-05/`:

```sh
lein new simple-layout exercises --to-dir chapter-05 -- 1.6.0
```

That's really all there is to it. The rest of this post explains the thinking behind the template's development.

## Rationale

As I've been working through [_Clojure for the Brave and True_][cfbt], one aspect that's been frustrating is creating new projects for the code samples and exercises that accompany each chapter. There are basically two options: create a directory with a `deps.edn` file or create a project with Leiningen.

[cfbt]: https://www.braveclojure.com/clojure-for-the-brave-and-true/

The former is simpler and seems like it should be the right way to do it but it comes with frustrating downside. When you launch a REPL from Emacs with Cider, it won't pick up and start you in a particular namespace (since there's no project from which to pull this information, this makes sense). You can switch to the namespace within the REPL but if you do that, you'll lose direct access to `clojure.repl` functions like `doc`. You can bring these in, of course, but having to do this each time you launch the REPL is frustrating.

Using Leiningen to create a project with either the default or app template doesn't have the namespace problem (since Cider will pick up the namespace that's set in `project.clj`) but it will create a structure for your code that seems like overkill for these kind of quick coding explorations.

Of course, one thing that's great about Leiningen is the community around it and while searching on Clojars I came across the [flat-layout][cj-fl] template by [@knjname][twt]. This _almost_ did what I wanted but with two limitations:

[cj-fl]: https://clojars.org/flat-layout/lein-template

[twt]: https://twitter.com/knjname

1. The template for the `<project-file>.clj` that it creates includes a `main` function. That's not the end of the world but if you don't need it, it can be frustrating to see it there.

2. The `project.clj` file hard codes a particular version of Clojure to use as a dependency. At the time of writing, that's version 1.6.0. If you want to use a different version, you need to update the project file each time.

The simple-layout template addresses both of these issues. You don't get anything in your `<project-name>.clj` file except a namespace declaration and you can always specify the version of Clojure you want by passing a template argument at runtime.

I hope to keep the simple-layout template updated to use the latest version of Clojure version as the default but, at least with the template argument, you're not dependent on me doing that should things change.