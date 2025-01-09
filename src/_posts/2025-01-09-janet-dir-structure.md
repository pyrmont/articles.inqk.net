---
title: "Recommended Directory Structure for Janet Packages"
layout: post
date: 2025-01-09 08:56:00 +0900
excerpt: "A recommended directory structure for use by Janet package authors."
category: 
tags: 
---

I like making packages for the Janet programming language. I also like things to be neat and consistent. This has led to me spending too much time thinking about a directory structure I can use for my Janet packages.

My suggestion is as follows:

```
<package>/
├─ bin/
├─ deps/
├─ lib/
├─ res/
├─ src/
├─ test/
├─ init.janet
├─ LICENSE
├─ project.janet
├─ README.md
```

To explain:

- `bin/`: This directory contains the binscripts that your package may provide. In my [Lemongrass][lg] package, for example, I provide a CLI utility, `lg`, that is installed together with the package.

[lg]: https://github.com/pyrmont/lemongrass "Visit the GitHub repository for the Lemongrass package."

- `deps/`: This directory contains vendored dependencies that your package uses. I’ve moved to using vendored dependencies as a way to avoid some of the issues that arise when you’re trying to share dependencies across all packages.[^1]

- `lib/`: This directory contains the Janet code that is used in your package.

- `res/`: This directory contains resources (such as fixtures used in testing) that are used by your package.

- `src/`: This directory contains code (typically C code) that is compiled for use in your package.

- `test/`: This directory contains tests for your package (the Janet Package Manager includes a built-in task `jpm test` that will run all Janet files in the `test/` directory).

- `init.janet`: This file allows a consumer of your package to import the entire library by simply writing `(import <package>`) in their Janet file. This is because `init.janet` is a 'magic file' that Janet's module loader looks for when it tries to resolve an import call. In my [Digestive][dg] package, the MD5 module that is located in `lib/md5.janet` is exported by `init.janet` with the `md5` prefix. This translates to the following usage:

  ```janet
  (import digestive)
  
  (digestive/md5/digest "Hello world")
  ```

  My documentation tool, [Documentarian][doc], can be used with the `-O` and `-d` flags to only document functions that are exported from a file (e.g. `init.janet`) and remove the prefix (e.g. `init/`) that would otherwise prefix each binding.

[dg]: https://github.com/pyrmont/digestive "Visit the GitHub repository for the Digestive package."

[doc]: https://github.com/pyrmont/documentarian "Visit the GitHub repository for the Documentarian package."

- `project.janet`: This file sets up the package for use by JPM, the Janet Package Manager. For libraries written in Janet that follow this directory structure, `declare-source` should be called with the files to copy on installation of the package together with a prefix (typically the name of the package).

  Using Digestive as an example again, this looks like:

  ```janet
  (declare-source
    :source ["deps"
             "lib"
             "init.janet"]
    :prefix "digestive")
  ```

(I've left out descriptions for `LICENSE` and `README.md` which I assume are self-explanatory.)

I've been using this structure for a few months now and have found it works well. I hope it does for you, too!

[^1]: I’m still working on the best way to install and update vendored dependencies. I have some ideas but nothing I’m certain is the right answer.
