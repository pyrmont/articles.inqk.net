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
  resources; and
- is installable.

Making a directory isn't that difficult but how do you make something
'installable'?

### Bundle Types

Unfortunately, for historical reasons, Janet has two types of bundles.

First, there are **legacy bundles**.[^lb1] A legacy bundle is made installable
by the presence of a file titled `project.janet` in the _bundle root_. Legacy
bundles were developed to work with the Janet Project Manager (commonly
referred to as `jpm`). A legacy bundle cannot be installed by the `janet`
binary alone.[^lb2]

Second, there are **modern bundles**.[^mb] A modern bundle is made installable
by the presence of an _info file_ and a _bundle script_.[^ib] Once you get a
bundle on the local file system, it can be installed by the `janet` binary
alone.

It is possible for a bundle to be _both_ a legacy bundle and a modern bundle if
the bundle includes all the necessary files (a `project.janet` file, an info
file and a bundle script).

## Artifacts

Saying that a bundle is 'installable' really means that it has _artifacts_ that
can be installed. Janet has built-in support for installing and uninstalling
artifacts from modern bundles. The `janet` binary cannot install artifacts from
legacy bundles without an additional tool.

Installing a bundle means copying one or more of the following artifacts into
the _syspath_:

1. a **module file** in Janet
2. an **executable file** in Janet
3. a **compiled module file** in machine code
4. a **compiled executable file** in machine code
5. a **man page file**

Uninstalling means removing the files that were copied.

When installing a modern bundle, Janet creates a _manifest_ that, among other
things, lists all of the paths that were created during installation. As a
result, Janet can make sure those paths are removed when the bundle is
uninstalled.

## syspath

In Janet, the _syspath_ is a special directory on the file system where Janet
will install artifacts, save bundle data[^bd] and (perhaps most important)
look for modules to load.

On POSIX systems, the default syspath is:

- `/usr/local/lib/janet`

If installed via Homebrew, it is:

- `/opt/homebrew/lib/janet`

While on Windows, the default syspath is:

- `%APPDATA%\Janet\Library`

Inside the syspath are three reserved directories:

- `<syspath>/bin`
- `<syspath>/bundle`
- `<syspath>/man`

These are discussed below.

## Manifest

The _manifest_ is a collection of metadata concerning an installed bundle. It
is created during the installation process by Janet and saved in
`<syspath>/bundle/<bundle-name>/manifest.jdn`.

## Bundle Root

I use the term _bundle root_ to refer to the top-level of the bundle itself.
Where paths in this article are of the form `./foo.bar`, this refers to a file
called `foo.bar` that is at the top-level of the bundle (i.e. the bundle root).

Janet does not mandate a structure for the bundle but, as noted above, modern
bundles should contain an info file and a bundle script.

## Info File

The _info file_ is a text file written in JDN (Janet data notation). The info
file can be located in one of two places relative to the bundle root:

1. `./bundle/info.jdn`
2. `./info.jdn`.

The file must describe a single data structure, either a struct or table, that
maps the key `:name` to a string value that represents the name of the bundle.
Note that the name of the bundle is used as the name of the subdirectory within
`<syspath>/bundle` directory. For this reason, two bundles cannot be installed
with the same name.

The info file should also list the external dependencies of the bundle (if any).
This information is stored as an array/tuple that is associated with the key
`:dependencies` at the top-level of the data structure. During the installation
process, Janet will confirm that the dependencies listed are installed before
proceeding with installation.

Here's an example of an info file:

```janet
{:name "foo"
 :version "1.0.0"
 :description "Just adds all the foo"
 :author "A Programmer"
 :license "MIT"
 :url "https://example.org/foo"
 :repo "git+https://example.org/foo"
 :dependencies [{:name "bar"
                 :url "https://example.org/bar"}]
 :artifacts {:libraries [{:prefix "foo"
                          :paths ["init.janet"
                                  "lib"]}]
             :manpages ["man/man1/foo.1"]
             :scripts [{:path "bin/foo"}]}}
```

In addition to `:name` and `:dependencies`, this example includes several other
keys. Some of these, like `:description`, are more for communicating to the
potential consumer. Some, like `:artifacts` , may be used by a particular
bundle script.[^bs]

## Bundle Script

The _bundle script_ is a text file containing Janet code. The bundle script can
be located in one of two places relative to the bundle root:

1. `./bundle/init.janet`
2. `./bundle.janet`

As discussed below, the bundle script contains functions that will be called
during the installation and uninstallation process.

It is important to note that, before any functions are called, the info file
and bundle script are copied to `<syspath>/bundle`. Both files are placed
inside a subdirectory with the same name as the bundle (i.e.
`<syspath>/bundle/<bundle-name>`). Janet in fact copies all files from the
bundle's `./bundle` directory to `<syspath>/bundle/<bundle-name>`.

As a result, a bundle script can import other modules but it **should not** do
this relative to directories in the bundle root since at the time of
evaluation, the bundle script will be located in
`<syspath>/bundle/<bundle-name>`. If a user's bundle script depends on modules,
these should be imported from the syspath:

```janet
(import foo)
```

or they should be included in the bundle's `./bundle` directory and then imported
relative to the bundle script:

```janet
(import ./foo)
```

You can see an example of doing this in the [bundle script][pe] for Predoc, my
tool for generating man pages.

[pe]: https://github.com/pyrmont/predoc/blob/ad43c7b3e48b65111fd95c62f604910791c5a10f/bundle/init.janet

## Bundle Hooks

Janet deliberately leaves the logic for installing artifacts to the bundle
author. It does this by using _bundle hooks_. A bundle author can think of a
bundle hook as a call to an identically named function in the bundle’s bundle
script.

Janet calls up to five hooks during the installation process:

1. `postdeps`[^pd]
2. `clean` (optional)
3. `build`
4. `install`
5. `check` (optional)

The optional hooks are only called if specified in an argument to
`bundle/install`.

One hook is called during the uninstallation process:

1. `uninstall`

As noted above, each bundle hook effectively calls an identically named
function in the bundle script. The function is called with the data in the
manifest as its first argument. This importantly includes the information in
the info file under the `:info` key.

If a bundle author doesn’t define a function for a particular hook, nothing
happens and Janet moves onto the next hook. Some bundles don’t need a build
step, for example, and so can simply not define a `build` function. Others may
not need a `postdeps` function.

Every bundle script should include an `install` function and this function
should make calls to some combination of `bundle/add`, `bundle/add-directory`,
`bundle/add-bin` and `bundle/add-manpage` to copy various artifacts into the
syspath. Using these functions ensures that the paths created are saved in the
manifest and so can be properly removed during the uninstallation process.

## Conclusion

Janet bundles are still a bit of a work in progress and the suggested terms here
are just that: suggestions. If you have questions, the [GitHub repository][gh]
is a good place to ask.

[gh]: https://github.com/janet-lang/janet

[^lb1]: This is my term of art. Use it at parties to sound cool.

[^lb2]: Legacy bundles are not a focus of Jeep and so are not discussed further
in this article. More information about legacy bundles is available on the
[Janet website][docs].

[docs]: https://janet-lang.org/jpm/

[^mb]: Again, sound cool at parties.

[^ib]: Strictly speaking, you can install bundles without these files but this
isn't documented at the time of writing and I think it is simpler to treat these
files as being required.

[^bd]: The bundle manifest, the info file and the bundle script.

[^bs]: Bundle scripts generated by Jeep look for this key to determine which
artifacts to install.

[^pd]: Previously `dependencies`.
