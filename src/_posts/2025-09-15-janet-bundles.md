---
title: "Bundles in Janet"
layout: post
date: 2025-09-15 00:44:09 +0900
excerpt: "A summary of my understanding of bundles in Janet."
category:
tags:
---

I'm currently working on [Jeep][jeep], a bundle manager for the Janet
programming language. As you might expect, I've had to learn quite a bit about
how bundles work in Janet. This post summarises my understanding.

[jeep]: https://github.com/pyrmont/jeep

## Bundle

A _bundle_ is Janet’s term for what some languages call a package. At its most
basic, a bundle:

1. is a directory of files that can contain Janet code, documentation and other
   resources, that
2. is intended for installation.

## Bundle Types

Unfortunately, for historical reasons, Janet has two types of bundles.

First, there are **legacy bundles**.[^lb] A legacy bundle includes a file titled
`project.janet` in the bundle root. It cannot be installed by the `janet` binary
alone.

Second, there are **modern bundles**.[^mb] A modern bundle includes an _info
file_ and a _bundle script_. Once a bundle is on the local file system, it can
be installed by the `janet` binary alone

It is possible for a bundle to be _both_ a legacy bundle and a modern bundle if
the bundle includes all the necessary files.

## Targets

Janet has built-in support for installing and uninstalling modern bundles using
`bundle/install` and `bundle/uninstall` respectively. Janet cannot install
legacy bundles without an additional tool.

Installing a bundle means copying one or more of the following _targets_[^of] into a
_target path_:[^tp]

1. a **module** written in Janet
2. a **native module** compiled to machine code
3. an **executable** written in Janet
4. a **native executable** compiled to machine code
5. a **man page**

Uninstalling means removing the files that were copied. Janet’s `bundle/install`
function creates a manifest that lists the files that were installed. As a
result, `bundle/uninstall` can make sure those files are removed when the bundle
is uninstalled.

## Target Paths

A user can think of Janet as having three _target paths_:

1. the **syspath**
2. the **binpath**
3. the **manpath**

On POSIX, the system paths systems default to:

1. `/usr/local/lib/janet`
2. `/usr/local/lib/janet/bin`
3. `/usr/local/lib/janet/man`

On Windows, the system paths default to:[^windows]

1. `%APPDATA%/Janet/Library`
2. `%APPDATA%/Janet/bin`
3. `%APPDATA%/Janet/docs`

For modules, the syspath is the most important as it is the path which Janet
uses to search when importing modules.

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
`./bundle/info.janet` and `./bundle.janet`.

As noted above, each bundle hook calls an identically named function in the
bundle script. If a bundle author doesn’t have a function with that name,
nothing happens and `bundle/install` moves onto the next hook. Some bundles
don’t need a `build` step, for example, and so can simply not define that
function. Others may not need a `dependencies` or `check` function.

A bundle script can import other modules but it should only do that relative to
the `./bundle` directory. This is because this directory is installed separately
to other files by `bundle/install`. If a user has dependencies, they should
either have these be imported from the syspath (e.g. `(import foo)`) or they
should have them contained within the `./bundle` directory (e.g. `(import
./foo)` in a directory that contains `foo.janet`).

### Info File

The _info file_ is a text file written in JDN (Janet data notation). The info
file can be located in one of two places relative to the root of the bundle:
`./bundle/info.jdn` and `./info.jdn`.

The file must describe a single data structure, either a struct or table, that
maps the key `:name` to a string value that represents the name of the
bundle.[^name]

The info file should also list the external dependencies of the bundle (if any).
This information is stored as an array/tuple that is associated with the key
`:dependencies` at the top-level of the data structure. Janet’s `bundle/install`
function will confirm that the dependencies listed are installed before
proceeding with installation.

The info file may further contain other information that is used by the bundle
script. The info file for Jeep currently looks like this in part:

```janet
{:name "jeep"
 :version "DEVEL"
 :description "A Janet bundle manager"
 :author "Michael Camilleri"
 :license "MIT"
 :url "https://github.com/pyrmont/jeep"
 :repo "git+https://github.com/pyrmont/jeep"

 # <...>

 :executable ["bin/jeep"]
 :manpage ["man/man1/jeep.1"
           "man/man1/jeep-build.1"
           "man/man1/jeep-clean.1"
           "man/man1/jeep-dep.1"
           "man/man1/jeep-install.1"
           "man/man1/jeep-prep.1"
           "man/man1/jeep-quickbin.1"
           "man/man1/jeep-test.1"
           "man/man1/jeep-uninstall.1"]
 :source {:prefix "jeep"
          :files ["deps" "lib"]}}
```

## Conclusion

Janet bundles are still a bit of a work in progress and the information here is
subject to change. If you have questions, the [GitHub repository][gh] is a good
place to ask.

[gh]: https://github.com/janet-lang/janet

[^lb]: This is my term of art. Use it at parties to sound cool.

[^mb]: Again, sound cool at parties.

[^of]: Techically speaking, it is possible to copy other types of files. In
practice, most bundles will only copy one or more of the files listed.

[^tp]: I don't actually want to coin all these terms. The problem is that there
don't seem to be any. Alternate suggestions welcome.

[^windows]: Unlike the POSIX version of the `janet` binary, the Windows version
does not hard code any values and instead uses environment variables
exclusively. If a user's system does not specify any of `JANET_PATH`,
`JANET_BINPATH` and `JANET_MANPATH`, then the target paths will not resolve to a
value by default.

[^name]: Bundle names are used as the name of subdirectories within the
`<syspath>/bundle` directory where information on installed bundles is kept. For
this reason, two bundles cannot be installed with the same name.
