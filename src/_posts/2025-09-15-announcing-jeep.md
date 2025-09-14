---
title: "Announcing Jeep"
layout: post
date: 2025-09-15 00:44:09 +0900
excerpt: "An announcement of Jeep, a bundle manager for Janet."
category:
tags:
---

# Announcing Jeep

[Jeep][ghr] is a bundle manager for the Janet programming language. If you use
Janet, I think you should use it. It has better documentation, does a great job
supporting vendoring and can make testing a more enjoyable experience. You can
install it like this:

```console
$ git clone https://github.com/pyrmont/jeep
$ cd jeep
$ janet ./lib/cli.janet install
```

[ghr]: https://github.com/pyrmont/jeep

In this post, I’ll explain some of the concepts involved in Janet’s bundle
system. Then I’ll try to explain how Jeep works, why I made the decisions that I
did and why those decisions might not be right for you.

## Concepts

### Bundles

A _bundle_ is Janet’s term for what some languages call a package. At its most
basic, a bundle is a directory of files that can contain Janet code,
documentation and other resources.

There are two types of bundles:

1. **legacy bundles**, these include a `project.janet` in the bundle root
2. **modern bundles**, these include an _info file_ and a _bundle scripts_

### Installing and Uninstalling

Janet has built-in support for installing and uninstalling modern bundles using
`bundle/install` and `bundle/uninstall` respectively. Janet cannot install
legacy bundles without an additional tool.

Installing a bundle means copying one or more of the following into a _system
path_:

1. a module in Janet
2. a native module in machine code that is compiled during installation
3. an executable in Janet
4. a native executable in machine code that is compiled during installation
5. a man page

Uninstalling means removing the files that were copied. Janet’s `bundle/install`
function creates a manifest that lists the files that were installed. As a
result, `bundle/uninstall` can make sure those files are removed when the bundle
is uninstalled.

### System Paths

A user can think of Janet as having three _system paths_:

1. the syspath
2. the binpath
3. the manpath

For libraries, the syspath is the most important as it is the path which Janet
uses to search when importing modules. By convention,[^convention] the system
paths on POSIX systems are:

1. `/usr/local/lib/janet`
2. `/usr/local/lib/janet/bin`
3. `/usr/local/lib/janet/man`

On Windows, the system paths are:[^windows]

1. `%APPDATA%/Janet/Library`
2. `%APPDATA%/Janet/bin`
3. `%APPDATA%/Janet/docs`

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
be located in one of two places relative to the root of the bundle:
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
script.

## Jeep

So why do you need Jeep? Well, while Janet can install bundles that are on the
local file system, that’s all it can do. What if you want to install bundles
that aren’t on the local file system? What if you have dependencies that you
need to install? What if you want to develop a bundle? This is where Jeep can
help.

### Features

Jeep’s functions can be broken down into global and bundle-level commands. The
global commands can be run anywhere. The bundle-level commands must be run
inside a bundle’s root.

The global commands:

1. `install`
2. `quickbin`
2. `uninstall`

The bundle-level commands:

1. `build`
2. `clean`
3. `dep`
4. `prep`
5. `test`

Command names try to be descriptive of their function but Jeep comes with
comprehensive documentation in its man pages if you want to understand any
command better. The man page for each command can be accessed by calling the
command with the `--help` option (`-h` will display the usage information):

```console
$ jeep prep --help
```

### Philosophy

The primary goal of Jeep is be a bundle management tool that doesn’t lock you
in. If you ever want to stop using Jeep, your project should be able to switch
without any direct impact on your users’ ability to install your bundle.

To that end, Jeep embraces modern bundles: in other words, info files and bundle
scripts. At a minimum, you will need to write an install function that installs
the files necessary for your bundle. If your bundle contains a single-module
file `foo.janet`, this can be as simple as this:

```janet
(defn install [manifest &]
  (bundle/add manifest "foo.janet" "foo/init.janet"))
```

If you have an executable called `foo` in `./bin`, it might be:

```janet
(defn install [manifest &]
  (bundle/add-bin manifest "bin/foo"))
```

Of course, if you want, you can get a lot more elaborate. Here’s Jeep’s own
`install` function. It adds man pages, Janet modules and a binscript:

```janet
(defn install [manifest &]
  (def seps {:windows "\\" :mingw "\\" :cygwin "\\"})
  (def s (get seps (os/which) "/"))
  # install man pages defined under :manpage
  (def manpages (get-in manifest [:info :manpage] []))
  (os/mkdir (string (dyn :syspath) s "man"))
  (os/mkdir (string (dyn :syspath) s "man" s "man1"))
  (each mp manpages
    (bundle/add-file manifest mp))
  # install modules defined under :source
  (def prefix (get-in manifest [:info :source :prefix]))
  (def srcs (get-in manifest [:info :source :files] []))
  (bundle/add-directory manifest prefix)
  (each src srcs
    (bundle/add manifest src (string prefix s src)))
  # install executables defined under :executable
  (def bins (get-in manifest [:info :executable] []))
  (each bin bins
    (bundle/add-bin manifest bin)))
```

### Implementation

Janet’s bundle functions are deliberately simple with a decent amount left to
bundle authors to define in their bundle script. The primary library that
assists bundle authors in this respect is Spork. Spork describes itself as the
‘official “Contrib” library’ amongst its many modules are a few that are useful
for bundle management and development.

But Spork is a collection of disparate modules and it’s unlikely that any one
codebase requires all of it.  What’s more, some of the modules are native and
require compilation. What if you want a bundle manager on a system where you
don’t want (or perhaps can’t) compile native code? Jeep to the rescue!

Jeep takes the bundle-related modules and vendors them into its repository. This
gives you the power of Spork’s bundle tooling without needing to lug around all
the other pieces that come with it.

### Key Features

#### Documentation

I’m also the author behind [Predoc][predoc] and unsurprisingly Jeep has
excellent man pages. If you are curious about how anything works, pass `--help`
to the command you are trying to run.

[predoc]: https://pyrmont.github.io/jeep

#### Vendoring

Jeep encourages its users to vendor dependencies and provides top-notch support
for doing this in your bundle. Jeep’s `dep` command can easily add a dependency
under a `:vendored` key in the info file. This information can then be used by
the `prep` command to vendor these dependencies into the bundle itself.

#### Testing

Jeep offers the ability to easily run the tests that a user has defined in a
`./test` directory. It also recognises that sometimes you don’t need all your
tests to run. To that end, Jeep offers the ability to run/not run individual
files and run/not run individual tests.

### Limitations

Jeep’s most controversial decision is the choice **not to support** legacy
bundles (i.e. those using `project.janet`). At the time of writing, this is
_almost all_ Janet bundles. Why would I do something like this? The simple
answer is that I believe that modern bundles are the future and I want to do
what I can to encourage bundle authors to make their compatible. `janet-pm`
makes the pragmatic decision to support bundles that contain a `project.janet`
file; Jeep does not.

### Alternatives

Let’s see how Jeep stacks up against the alternatives: `jpm` and `janet-pm`.

#### `jpm`

Before the modern bundle was introduced in 2024, there were only legacy bundles.
These required the use of the Janet Project Manager or [`jpm`][jpm]. Janet
Program Manager remains the most popular bundle manager despite its ‘legacy’
status.

[jpm]: https://github.com/janet-lang/jpm

In comparison to Jeep, `jpm` is not as cleanly architected and depends upon
Janet’s `use` function to bring functions from other modules into the
environment of the individual file. This makes it difficult to understand when
reading the source code since it’s not obvious where functions are defined. This
represents a challenge for future maintenance.

Worse, legacy bundles are not able to easily present bundle-related information
to consumers. Bundle information is in the `project.janet` file but since that
file is an ordinary Janet file, there is nothing to stop it containing function
calls. Indeed, the `project.janet` format depends upon it as a number of
functions are used so that the user can write code like `(declare-project)` and
`(declare-source)` that looks declarative but isn’t.

#### `janet-pm`

[`janet-pm`][janet-pm] is in many ways an updated version of `jpm` that add
support for modern bundles. As may be expected, it better separates its modules
and is easier to maintain.

[janet-pm]: https://github.com/janet-lang/spork

The problem is that `janet-pm` is part of Spork and requires it to be installed
as well. Since Spork includes natively compiled modules, this means that
`janet-pm` cannot be installed without a functioning compiler.

## Conclusion

If you’ve read this far, I hope you’re inspired to give Jeep a try. I hope you
find it an extremely pleasant experience.

[^convention]: The location of paths is in some degree of flux at the moment.
The binpath and manpath are set differently by `jpm` and `janet-pm`. Given the
description of `jpm` as ‘legacy’, the `janet-pm` is treated as defining the
current conventional locations.

[^windows]: The Windows version of the `janet` binary uses environment variables
to specify the system paths. Some users may not have the system paths set if
they do not have environment variables defined for `JANET_PATH`, `JANET_BINPATH`
and `JANET_MANPATH`.

[^name]: Bundle names are used as the name of subdirectories within the
`<syspath>/bundle` directory where information on installed bundles is kept.
For this reason, two bundles cannot be installed with the same name.
