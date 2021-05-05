---
title: "How-To: Creating an iPhone 12 in Pure CSS to Frame an App Screenshot"
layout: post
date: 2021-05-05 17:31:49 +0900
excerpt: "Instructions on creating an iPhone 12 in Tailwind CSS that can be used in product marketing."
category: 
tags: 
---

After months of delay, I finally launched [Flext][] yesterday. One of the
things I'm moderately proud of is the product marketing page I designed to go
with the app and, in particular, the image of Flext running on an iPhone 12.

Calling it an 'image' is a little deceiving, though, because while the
screenshot is an image, the iPhone itself is pure CSS. How did I do it? The
majority of the code is from Fayaz Ahmed, a very talented developer who was
kind enough to [share his code][original] last December.

Ahmed used [Tailwind CSS][tw], a utility-first CSS framework. One of the things
that's especially great about Tailwind's approach is that it makes copying and
pasting markup elements exceptionally simple.

With Ahmed's code in hand, I only needed to make a few minor tweaks. Ahmed's
code amazingly reproduces the entire iPhone—homescreen and all. I just needed
an iPhone to frame the screenshot of Flext I'd already taken. A few edits
later, here was my code:

```html
<div class="flex items-center justify-center">
  <div class="relative">
    <div class="h-6 w-0.5 rounded-l-sm bg-green-500 absolute -left-0.5 top-16"></div>
    <div class="h-8 w-0.5 rounded-l-sm bg-green-500 absolute -left-0.5 top-28"></div>
    <div class="h-8 w-0.5 rounded-l-sm bg-green-500 absolute -left-0.5 top-40"></div>
    <div class="h-auto w-64 bg-green-500 rounded-4xl p-1 overflow-hidden">
      <div class="h-full w-full bg-black rounded-4xl overflow-hidden p-2 relative">
        <div class="w-28 h-6 bg-black absolute left-1/2 rounded-b-2xl transform -translate-x-1/2"></div>
          <img class="rounded-4xl" src="/path/to/screenshot.png" alt="App Screenshot" title="Your App"/>
        </div>
      </div>
      <div class="h-14 w-0.5 rounded-l-sm bg-green-500 absolute -right-0.5 top-32"></div>
  </div>
</div>
```

The class `rounded-4xl` is custom and will require editing your
`tailwind.config.js`:

```js
module.exports = {
  ...
  theme: {
    extend: {
      borderRadius: {
        '4xl': '2rem'
      },
    },
  },
  ...
}
```

And that's it! Thanks to Ahmed. You're a legend. If you're curious, the full text
for the Flext product marketing page is [available on GitHub][repo].

[Flext]: https://apps.inqk.net/flext/ "The product page for Flext"

[original]: https://dev.to/fayaz/got-bored-and-made-iphone-12-with-tailwindcss-l4p "Read 'Got bored and made iPhone 12 with Tailwindcss'"

[tw]: https://tailwindcss.com "The Tailwind CSS website"

[repo]: https://github.com/pyrmont/apps.inqk.net "The repository for apps.inqk.net on GitHub"
