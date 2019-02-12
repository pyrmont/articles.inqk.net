---
title: "How-To: Use a Custom Theme in Spacemacs"
layout: post
date: 2019-02-12 13:59:13 +0900
excerpt: "Instructions on how to use a custom theme in Spacemacs."
category: 
tags: 
---

Spacemacs is a great way for new users to get into Emacs. Having a curated collection of packages helps ease you into the vast Emacs ecosystem while allowing you to be productive right away. As you become more familiar with Emacs, you can begin customising the editor to your liking.

## Adding a Custom Theme

One way you might want to make your installation your own is by adding a custom theme. Custom themes can be located wherever you prefer but a good place to put them is in the `private` directory within `.emacs.d`.

I've recently made[^1] a custom theme[^2] called [spacemax-theme][] and have it located within `.emacs.d/private/themes/spacemax-theme`. To tell Spacemacs where it is, I need to do the following in my `.spacemacs` file.

[spacemax-theme]: https://github.com/pyrmont/spacemax-theme

1. Add the name of the theme(s) to the list that's provided to `dotspacemacs-themes`:

   ```el
   dotspacemacs-themes '(spacemax-dark
                         spacemax-light)
   ```

2. Add the location of the theme(s) to the definition of the `dotspacemacs/user-init` function :

   ```el
   (defun dotspacemacs/user-init ()
     (add-to-list 'custom-theme-load-path "~/.emacs.d/private/themes/spacemax-theme/")
   )
   ```

## Using `require` in Your Theme

One potential gotcha with using custom themes in Spacemacs is how to correctly `require` shared code. The location of your theme's directory is not automatically added to the Emacs load-path and so you can't simply type `(require '<some-filename>)` as you might expect.

In the case of spacemax, since so much code is shared between the light and dark variants, both themes pull in their common code from `spacemax-common.el`. To do this, we take advantage of the fact that `require` can take an optional second argument that specifies the location of the file where the code is located.

So instead of writing:

```el
(require 'spacemax-common)
```

as we typically would, we instead write:

```el
(require 'spacemax-common "~/.emacs.d/private/themes/spacemax-theme/spacemax/spacemax-common.el")
```

Hard coding the path into the file is a little ungainly but I haven't found an alternative. Do you know of a way? Inquiring minds want to know!

[^1]: I use 'made' in the loosest sense of the word. spacemax-theme is really just a relabelling of [spacemacs-theme][], the default theme that ships with Spacemacs. The impetus behind forking it was to bring the updates to the theme to version 0.200.13 of Spacemacs.

[spacemacs-theme]: https://github.com/nashamri/spacemacs-theme.

[^2]: spacemax-theme is really two themes: spacemax-dark and spacemax-light.