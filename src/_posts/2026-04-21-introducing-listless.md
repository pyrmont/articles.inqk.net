---
title: "Introducing Listless"
layout: post
date: 2026-04-21 12:53:37 +0900
excerpt: "An announcement post about Listless, a to-do list app for Apple platforms made using LLM-based coding agents."
category:
tags:
---

[Listless][] is an intentionally minimal to-do list app for Apple platforms. It is limited to one list that's synced across your devices. Items have a title, a position in the list and a completed status. It's free of charge and [open source][source].

[Listless]: https://apps.inqk.net/listless "Visit the official website for Listless"

[source]: https://github.com/pyrmont/listless "Visit the Listless repository on GitHub"

And I typed almost none of it.

## Rationale

Yes, this is _another_ blog post about what it's like to use LLM-based coding agents. Yes, this would have been more timely two months ago. Since I've already taken my time, let me put things into the appropriate context by explaining my rationale first.

### Do Next

The first reason I made Listless is that I wanted a 'do next' app.

Apple's Reminders is the primary repository for my to-do lists. But I've always found it productive to have a place where I write—and crucially prioritise—the stuff I want to accomplish in the extremely short term (i.e. today or this weekend). This is my 'do next' list. It's not something I want to keep around and slowly work through. It's an aid to help me stay focused in the moment.

For years, I used the excellent [Clear](https://www.useclear.com/) to fill this need. Clear was (and still is) a to-do list app oriented around gestures. When it launched in 2012, it included iCloud sync between iPhone, iPad and the Mac. After going dormant for a few years, [it relaunched in 2024](https://techcrunch.com/2024/01/08/an-original-app-store-innovator-clear-relaunches-its-swipeable-to-do-list-app-with-in-app-perks/) with a new business model that required a subscription for iCloud syncing. I'm not philosophically opposed to subscription pricing but something about losing access to a capability that I previously had rubbed me the wrong way.

### Polished Slop

The second reason to make Listless is that I wanted to see whether you could use a coding agent to create a polished app. A hallmark of indie software for Apple's platforms has been its _niceness_. I grew up using Windows and didn't switch to the Mac until 2010. Like other long-time Windows users who switched to the Mac (Marco Arment, Casey Liss, Ben Thompson), I noticed that despite Windows having the reputation for the most software, if you cared about nice software, it was no contest: the Mac won easily.

Some would argue the niceness of Mac software has been in decline for years now thanks to the inexorable rise of Electron-based apps. Me. I would argue that. And you know, perhaps it's untenable for a company to justify bespoke native apps (especially for the Mac) when a tool like Electron exists. It's just business.

But what if you're an individual and not a company? What if it isn't just business? What if it is in fact just a hobby? AppKit, and the Cocoa family of APIs, were renowned for the incredible leverage they provided small development teams. Could coding agents increase the size of that lever still further?

But large language models are incredible slop-generation machines. I'm talking about using them to make _nice_ software. Aren't those things mutually exclusive? I didn't know. Are they? I wanted to find out.

## Reality

So in February of this year, I started a new project. Well, a sort of new project. The truth is that I'd tried to make a similar to-do list app a few years prior and it hadn't gone well. Back then, I'd made the iPhone version with SwiftUI and it hadn't worked well. But SwiftUI was more mature now. Maybe the promise of a cross-platform UI framework had been realised.

### Mac-First

Still, since it was critical for my purposes that I be able to use the app on my iPhone, my iPad and my Mac, I started with the macOS version (the platform with the weakest SwiftUI support).

Very quickly, I had something that 'worked' in the loosest possible sense of the word. I could add things to a list. Then I could mark the items as completed or not. Eventually, I got reordering functional. I struggled to get SwiftUI to work well with standard Mac user interaction paradigms for text fields (e.g. the insertion point when you click on text should be at the point clicked, not at the end of the text). In the end, I opted for a `NSViewRepresentable` hosting view into which I could put a traditional `NSTextField`.

I got so frustrated that at one point, I decided to make the app in good old-fashioned AppKit. Even with Claude Code’s help, I struggled to literally get a window to open (I am not exaggerating for effect). SwiftUI on the Mac is rough but I decided it was preferable.

Eventually, it felt like the Mac version could be made to be... well, maybe not as nice as I might have hoped but at least decent. And that felt like something of an achievement. I’ve only made [one app](https://apps.inqk.net/flext) for Apple’s platforms before Listless and I abandoned the Mac version after struggling to get anything halfway passable. This was better than that.

I still hadn’t typed in any code.

### SwiftUI Wrestling

I started on the iOS version and found myself fighting with SwiftUI in new ways. I suspected from the previous attempt that implementing a gesture-centric user interface would be a challenge. SwiftUI comes with numerous ‘semantic’ view objects (e.g. `List`) and in my experience if you stick to them, things work well. As soon as you try to do something that isn’t built in, you step into the World of Pain™.

Are gestures that important? For me they are. As noted above, Listless is my ‘do next’ app. It’s a way for me to quickly write-up a list of tasks to do. I fell in love with Clear because of the ability to create, reorder, complete and delete in simple gestures. If Listless couldn’t do that, well, why not just create a new ‘Do Next’ list in Reminders?

With `List` not suitable for my needs, I began the frustrating process of recreating it using trusty old `ForEach` and `ScrollView`. This is the point at which, had I not been doing this with a coding agent, I’m confident I would have given up.[^defeat] It was still exasperting at points. The most difficult aspect was getting the animation to look correct where pulling down when at the top of the list. When a user does this a new row is ‘revealed’ above the currently topmost row. At one especially low point, I almost abandoned the entire effort after discovering that the solution I had pieced together over a week or so was completely broken in iOS 26. (Thanks Liquid Glass!)

But I persevered. I tried to exhaust the patience of [@sogaiu][] and Eugenia (I did not succeed and am extremely grateful for all their help). I did actually type a few things (mainly integer values as I tweaked the responsiveness of certain things). I got something that I think is all right. It’s not as polished as it could be but I don’t think it’s slop either.[^hitch]

[@sogaiu]: https://github.com/sogaiu "Visit @sogaiu's profile on GitHub"

## Final Thoughts

Did I succeed in my goal? I think I did. The code is [open source][source] so you can judge for yourself. In a little over two months I made an app that runs on iOS, iPadOS, watchOS and macOS. Having overcome the frustrations of SwiftUI development, I feel like I came out the other side thanks in no small part to Claude Code and OpenAI Codex. I feel empowered and I'm excited for what I will create next.

[^defeat]: Honestly, if I’d really been programming by hand, I almost certainly would have admitted defeat trying to implement the insertion point thing on the Mac.

[^hitch]: Version 1.2.1 of Listless has an animation hitch that I see on my iPhone 14 Pro Max and which I consider needs to be fixed. I can recreate the issue reliably by doing a quick pull-down-to-create gesture from a cold start. Claude hypothesises that this is because the iOS version also uses a hosted view for the text field (`UIViewRepresentable` in its case) and that creating the UIKit objects and putting them into the SwiftUI hosting view is computationally intensive. I would like to instrument this more to understand exactly what’s slowing it down but I have to wait until I have an iPhone with a working connection port to do that using Apple’s tools. (At some point my Lightning port broke and the iPhone no longer recognises connections to it. Unfortunately, in order to pair an iPhone to a Mac so that you can do things like instrument debug builds of apps, you need to plug the phone into the computer by a cable.)