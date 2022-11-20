---
title: "Supporting Cross-Mentions"
layout: post
date: 2021-05-24 03:32:02 +0900
excerpt: "I added support to my blog for mentions that work across services."
category: 
tags: 
---

I added 'cross-mentions' to [my microblog][updates] this weekend. In Markdown, I can now write:

```
I'm @pyrmont:twitter.com on Twitter and @pyrmont:instagram.com on Instagram.
```

and it will be rendered in HTML as:

```html 
I'm <a href="https://twitter.com/pyrmont">@pyrmont</a> on Twitter and <a href="https://instagram.com/pyrmont">@pyrmont</a> on Instagram.
```

I accomplish this with a plug-in I wrote that transforms mentions of the form `@username:domain` into links of the form `<a href="domain/username">@username</a>`.

So far, so good. However, I took it a step further. I wrote another plug-in that cross-posts my blog updates to Twitter and, when it does, renders the text as:

```
I'm @pyrmont on Twitter and instagram.com/pyrmont on Instagram.
```

Doing this has the added benefit of removing the dependency I had on [Micro.blog][]. Micro.blog looks pretty stable and I don't think it's going anywhere but I ultimately like being in complete control of the content I publish online and having my own cross-posting plug-in is consistent with that philosophy.

If you're interested in the code, the [entire website][repo] is available on GitHub. The Markdown plug-in is [here][mentioner] and the cross-posting plug-in is [here][tweeter].

[updates]: https://updates.inqk.net "My microblog"

[Micro.blog]: https://micro.blog "The Micro.blog website"

[repo]: https://github.com/pyrmont/updates.inqk.net "The source for updates.inqk.net on GitHub"

[mentioner]: https://github.com/pyrmont/updates.inqk.net/blob/master/src/_plugins/commonmarker-mentions.rb "The mentioning plug-in on GitHub"

[tweeter]: https://github.com/pyrmont/updates.inqk.net/blob/master/src/_plugins/jekyll_posteriser.rb "The cross-posting plug-in on GitHub"
