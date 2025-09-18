---
title: "Recommended Directory Structure for Janet Bundles"
layout: post
date: 2025-09-18 17:07:37 +0900
excerpt: "A revised recommended directory structure for use by Janet bundle authors."
category: 
tags: 
---

**_In January 2025, I [recommended a directory structure][recommend] for what I
would now call Janet's legacy bundles. This post is a revised version for modern
bundles._**

[recommend]: https://articles.inqk.net/2025/01/09/janet-dir-structure.html "Read
the article 'Recommended Directory Structure for Janet Packages'."

I like making bundles for the Janet programming language. I also like things to
be neat and consistent. This has led to me spending too much time thinking about
a directory structure I can use for Janet bundles.

Here's what I've come up with:

```
<bundle>
├─ bin/
├─ bundle/
│  └─ init.janet
├─ deps/
├─ lib/
├─ res/
├─ src/
├─ test/
├─ info.jdn
├─ init.janet
├─ LICENSE
└─ README.md
```

To explain:

- `bin/`: This directory contains the binscripts[^bs] that your bundle will
  install. In [Lemongrass][lg], for example, I provide a CLI utility, `lg`,
  that is installed as part of the bundle.

[lg]: https://github.com/pyrmont/lemongrass "Visit the GitHub repository for the
Lemongrass bundle."

- `bundle/`: This directory contains your bundle script (`init.janet`) and any
  helper scripts necessary for managing your bundle. In [Predoc][pr], for
  example, I include a bunch of files from the [Spork][sp] library so that you
  can compile the `predoc` binary without anything other than the `janet`
  binary.[^compile]

[pr]: https://github.com/pyrmont/predoc "Visit the GitHub repository for the
Predoc bundle."

[sp]: https://github.com/janet-lang/spork "Visit the GitHub repository for the
Spork bundle."

- `deps/`: This directory contains vendored dependencies that your bundle uses.
  I've moved to using vendored dependencies as a way to avoid some of the issues
  that arise when you’re trying to share dependencies across all bundles.[^vend]
  If that sounds interesting, check out my bundle manager [Jeep][jp]. It makes
  vendoring dependencies as easy as can be.

[jp]: https://github.com/pyrmont/jeep "Visit the GitHub repository for the Jeep
bundle."

- `lib/`: This directory contains the Janet code that is used in your bundle.

- `res/`: This directory contains resources (images, testing fixtures, helper
  scripts) that are used by your bundle.

- `src/`: This directory contains code (typically C code) that is compiled for
  use in your bundle.

- `test/`: This directory contains tests for your bundle. If you're using a
  bundle manager like Jeep it comes with a `jeep test` command that runs all the
  tests in the `test` directory.

- `info.jdn`: This file contains metadata about your bundle written as a struct
  or table in Janet Data Notation (or JDN). The only mandatory key is `:name`
  but you can include other information that might be useful to your bundle
  script or to consumers of your bundle.

- `init.janet`: This file allows a consumer of your bundle to import the top
  level bindings by simply writing `(import <package>`) in their Janet file.
  This is because `init.janet` is a 'magic file' that Janet's module loader
  looks for when it tries to resolve an import call. So using Lemongrass as an
  example again, a consumer of the bundle can write:

  ```janet
  (import lemongrass :as lg)
  
  (lg/markup->janet "<p>Hello world</p>")
  ```

  This works even though the `mark-up->janet` function is defined in
  `lib/to-janet.janet` because `init.janet` imports this module file and then
  exports its bindings.

- `LICENSE`: The licence that you apply to your bundle.

- `README.md`: Your README in Markdown format.

If your bundle doesn't need any of the above directories, feel free to leave it
out.

I've been using this structure for the last six months or so and have found it
works well. I hope others find it helpful, too!

[^bs]: A _binscript_ is a text file that is marked executable and begins with
`#!/usr/bin/env janet`. This will cause the OS to run the Janet code in the file
through the `janet` binary installed on the user's system.

[^vend]: I’m still working on the best way to install and update vendored
dependencies. I have some ideas but nothing I’m certain is the right answer.

[^compile]: Seriously, just clone the repo, `cd` into the directory and then run
the following:

```console
janet -e '(import ./bundle) (bundle/build (table :info (-> (slurp "info.jdn") parse)))'
```
