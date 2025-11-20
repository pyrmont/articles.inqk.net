---
title: "Introducing Jeep"
layout: post
date: 2025-11-20 08:28:37 +0900
excerpt: "An announcement post about Jeep, a bundle manager for the Janet programming language."
category:
tags:
---

I'm excited to introduce [Jeep][], a bundle manager for the Janet programming
language.

[Jeep]: https://github.com/pyrmont/jeep "Visit the GitHub repository for the Jeep project."

A _bundle_ is the term used in Janet to describe a distributable collection of
files. It's akin to a package in Node, a gem in Ruby or a crate in Rust. In
v1.35.0, Janet gained the ability to install bundles without any additional
tooling. Prior to that, bundles were installed with [JPM][], the Janet Project
Manager.

[JPM]: https://github.com/janet-lang/jpm "Visit the GitHub repository for the JPM project."

Jeep is built around various _subcommands_. There are global subcommands that
can be used anywhere (e.g. `jeep install`, `jeep uninstall`) and local
subcommands that are run in the _bundle root_[^br] of a bundle (e.g. `jeep build`,
`jeep prepare`).

I think Jeep is cool but if you didn't develop it, you might reasonably have
some questions about why you would want to use it. The remainder of this
introduction is structured as a series of questions and answers.

### Q. If Janet can install bundles, what is the point of Jeep?

While Janet can install bundles, there are two key limitations:

1. Janet does not include any machinery to download remote bundles. You need to
   do that yourself.
2. Janet checks whether the dependencies of a bundle are installed but it
   doesn't download and install them for you.

Jeep comes with an `install` subcommand that will install a bundle, together
with any external dependencies that are listed in the bundle's _info
file_.

### Q. If JPM can install bundles, what is the point of Jeep?

JPM can install _legacy bundles_ but it cannot install _modern bundles_.[^lb]

### Q. Why do I want to use modern bundles?

Legacy bundles continue to work fine and there's no reason you _have_ to
change. For me, modern bundles are preferable for two reasons:

1. Modern bundles aren't tied to a particular tool. Once they're on the file
   system, Janet can install them. Legacy bundles works today but they depend
   on JPM. JPM itself lacks robust tests and its heavy use of `use` can make it
   difficult to read.
2. Modern bundles cleanly separate metadata (listed in a bundle's _info file_)
   from management logic (listed in the bundle's _bundle script_). This makes it
   easier for other tools to extract information from your bundle without
   needing to run any code. It also means that a tool that you're not tied to
   one particular bundle manager (even Jeep!).

### Q. Can I use Jeep to install legacy bundles?

No. I realise this might reasonably be a deal breaker for many people. If you
are installing a modern bundle but it depends on a legacy bundle, Jeep cannot
install it. janet-pm (discussed below) does not have this limitation.

### Q. Are there any alternatives?

Apart from JPM, the only other alternative at the time of writing is janet-pm.
janet-pm is part of the [Spork][] library, the official contrib library (and
one that many people install). janet-pm makes a best effort to install legacy
bundles and so can be a good solution for someone who wants one tool to support
both legacy and modern bundles.

[Spork]: https://github.com/janet-lang/spork "Visit the GitHub repository for the Spork project."

### Q. What are some cool things you can do in Jeep?

A few of the interesting subcommands:

- `jeep api`: This subcommand creates `api.md`, a Markdown file in your
  _bundle root_ that lists the function signatures and docstrings for the
  functions exposed by your module.

- `jeep list`: This subcommand lists information about your current Janet
  environment. This includes the bundles you have installed, the version of
  Janet you are running and relevant environment variables.

- `jeep test`: This subcommand runs the Janet files that are in `./test` similar
  to how `jpm test` works. Unlike JPM, Jeep can run specific files using the
  `-f` option for situations where you don't need to run the entire suite.

### Q. How can I learn more about Jeep's subcommands?

Jeep includes a rich suite of man pages that describe its features. You can
read them by typing `jeep help <subcommand>` at the command line. For those
who'd like to see what Jeep can offer before installation, the pages are
written in [Predoc][], a Markdown flavour that I developed. As Markdown,
they're readable as plain text right in the [GitHub repository][manpages].

[Predoc]: https://pyrmont.github.io/pyrmont "Visit the official Predoc website."

[manpages]: https://github.com/pyrmont/jeep/tree/master/man/man1 "See a listing of the manpages in the GitHub repository."

### Q. Is there some way I can convert a legacy bundle into a modern bundle?

Yes. Jeep's `enhance` subcommand can be run in the _bundle root_ of a legacy
bundle and it will attempt to create the files for a modern bundle while
preserving the metadata encoded in the legacy bundle's `project.janet`.

----

Do you have more questions? Feel free to open an issue in the [Issues
section][issues] of the GitHub repository.

[issues]: https://github.com/pyrmont/jeep/issues "Visit the Issues section of the GitHub repository for the Jeep proejct."

[^br]: This article uses terminology I defined in my post ['Bundles in Janet'][terminology].

[terminology]: https://articles.inqk.net/2025/09/15/janet-bundles.html "Read the blog post 'Bundles in Janet'."

[^lb]: At least at the time of writing.
