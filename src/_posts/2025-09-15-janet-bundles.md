---
title: "Bundles in Janet"
layout: post
date: 2025-09-15 00:44:09 +0900
excerpt: "Suggested terminology for concepts related to Janet's bundles."
category:
tags:
---

I'm currently working on [Jeep][jeep], a bundle manager for the Janet
programming language. As you might expect, I've had to learn quite a bit about
how bundles work in Janet. One of the things that I've struggled with is what to
call various aspects. In this post, I want to describe some of the concepts and
suggest some terminology for the Janet community to consider using.

[jeep]: https://github.com/pyrmont/jeep

## Bundle

A _bundle_ is Janet’s term for what some languages call a package. At its most
basic, a bundle:

- is a directory of files that can contain Janet code, documentation and other
  resources

that

- is installable.

Making a directory isn't that difficult but how do you make a directory
'installable'?

## Bundle Types

Unfortunately, for historical reasons, Janet has two types of bundles.

First, there are **legacy bundles**.[^lb] A legacy bundle is made installable by
the presence of a file titled `project.janet` in the bundle root. Legacy bundles
were developed to work with the Janet Project Manager (commonly referred to as
`jpm`). A legacy bundle cannot be installed by the `janet` binary alone.

Second, there are **modern bundles**.[^mb] A modern bundle is made installable
by the presence of an _info file_ and a _bundle script_. Once you get a bundle
on the local file system, it can be installed by the `janet` binary alone.

It is possible for a bundle to be _both_ a legacy bundle and a modern bundle if
the bundle includes all the necessary files (a `project.janet` file, an info
file and a bundle script).

## Targets

Janet has built-in support for installing and uninstalling modern bundles using
`bundle/install` and `bundle/uninstall` respectively. As noted above, the
`janet` binary cannot install legacy bundles without an additional tool.

Installing a bundle means copying one or more of the following _targets_[^t]
into a _target path_:[^tp]

1. a **module file** written in Janet
2. a **native module file** compiled to machine code
3. an **executable file** written in Janet
4. a **native executable file** compiled to machine code
5. a **man page file**

Uninstalling means removing the files that were copied. Janet’s `bundle/install`
function creates a manifest that lists the files that were installed. As a
result, `bundle/uninstall` can make sure those files are removed when the bundle
is uninstalled.

## Target Paths

In theory, Janet should have three _target paths_:

1. the **syspath**
2. the **binpath**
3. the **manpath**

At the moment, **the manpath is not yet a target path**. Instead, there's the
syspath and the binpath. The binpath is created by appending `/bin` to the
systpath.

On POSIX systems, the default target paths are:

1. `/usr/local/lib/janet`
2. `/usr/local/lib/janet/bin`

On Windows, the default target paths are:

1. `%APPDATA%/Janet/Library`
2. `%APPDATA%/Janet/Library/bin`

The syspath is the most important as it is the path which Janet searches when
importing modules and the path from which the binpath is created.

### Bundle Hooks

Janet’s `bundle/install` function deliberately leaves the specifics of
installation to the bundle author. It does this by using _bundle hooks_. A
bundle author can think of a bundle hook as a call to an identically named
function in the bundle’s _bundle script_.

The `bundle/install` function calls five hooks:

1. `dependencies`
2. `clean`
3. `build`
4. `install`
5. `check`

The `bundle/uninstall` function calls one hook:

1. `uninstall`

### Bundle Script

The _bundle script_ is a text file containing Janet code. The bundle script can
be located in one of two places relative to the bundle root:

1. `./bundle/info.janet`
2. `./bundle.janet`

As noted above, each bundle hook calls an identically named function in the
bundle script. If a bundle author doesn’t have a function with that name,
nothing happens and `bundle/install` moves onto the next hook. Some bundles
don’t need a `build` step, for example, and so can simply not define that
function. Others may not need a `dependencies` or `check` function.

A bundle script can import other modules but it **should not** do it relative to
directories in the bundle root. This is because the `./bundle` directory[^b] is
installed separately to other files by `bundle/install`. If a user's bundle
script has dependencies, they should either be imported from the syspath:

```janet
(import foo)
```

or they should be imported from inside the `./bundle` directory:

```janet
(import ./foo)
```

### Info File

The _info file_ is a text file written in JDN (Janet data notation). The info
file can be located in one of two places relative to the bundle root:

1. `./bundle/info.jdn`
2. `./info.jdn`.

The file must describe a single data structure, either a struct or table, that
maps the key `:name` to a string value that represents the name of the bundle.
Note that bundle names are used as the name of subdirectories within the
`<syspath>/bundle` directory where information on installed bundles is kept. For
this reason, two bundles cannot be installed with the same name.

The info file should also list the external dependencies of the bundle (if any).
This information is stored as an array/tuple that is associated with the key
`:dependencies` at the top-level of the data structure. Janet’s `bundle/install`
function will confirm that the dependencies listed are installed before
proceeding with installation.

The info file may further contain other information that is used by the bundle
script. Here's a simple example:

```janet
{:name "foo"
 :version "1.0.0"
 :description "Just adds all the foo"
 :author "A Programmer"
 :license "MIT"
 :url "https://example.org/foo"
 :repo "git+https://example.org/foo"

 :dependencies [{:name "bar" :url "https://example.org/bar"}]

 :executable ["bin/foo"]
 :manpage ["man/man1/foo.1"]
 :source {:prefix "foo"
          :files ["init.janet" "lib"]}}
```

## Conclusion

Janet bundles are still a bit of a work in progress and the suggested terms here
are just that: suggestions. If you have questions, the [GitHub repository][gh]
is a good place to ask.

[gh]: https://github.com/janet-lang/janet

[^lb]: This is my term of art. Use it at parties to sound cool.

[^mb]: Again, sound cool at parties.

[^t]: Techically speaking, it is possible to copy other types of files. In
practice, most bundles will only copy one or more of the files listed here.

[^tp]: I don't actually want to coin all these terms. The problem is that there
don't seem to be any. Alternate suggestions welcome.

[^b]: This article uses the term 'bundle root' to refer to the top-level of the
bundle itself. However, a bundle can also put its info file and bundle script
inside a directory `bundle` that is located in the bundle root, i.e. `./bundle`.
Names are hard.
