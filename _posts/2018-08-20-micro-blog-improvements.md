---
title: "Improvements to Micro.blog"
layout: post
date: 2018-08-20 17:00:05 +0900 
excerpt: Some suggestions for ways to improve Micro.blog.
category: 
tags: []
---

The [latest Twitter blow-up][nyta] has resulted in an influx of people to Micro.blog. That's great but it's also meant a great deal of discussion _about_ Micro.blog. I worry that if the majority of discussion on a social network is about that social network, it's a warning sign of the viability of the platform (see: Google+). As a result, I've tried my best to post about things completely unrelated to Micro.blog in the past couple of days.

That said, while I share the fear that others might harbour about excessive navel-gazing, I also have thoughts about the ways in which Micro.blog could be improved! What better place to put them than on my blog! So, without further ado, here's improvements I'd like to see:[^1]

* **Third-Party Notification Infrastructure**: Micro.blog's developer, Manton Reece, [has said in the past][mra] that he'd like to implement a notification system that third party clients can use I'd really like to see this prioritised as the next new feature. Having to have the official Micro.blog client on my phone to ensure I get notifications that I then have to manually open in Icro to read is a sub-optimal experience.

* **Reactions**: Although Micro.blog is often seen as a Twitter replacement (I use it that way), Manton has been careful not to slavishly copy Twitter's features. This has been especially the case in respect of elements of Twitter's design that could/do have negative effects (eg. follower counts, one-click reblogging). One of the most noticeable is that there's no way to publicly 'like' a post by someone on Micro.blog. Supporters of this approach, argue that it promotes more meaningful engagement. Those on the other side (like me) point out that it typically results in people not engaging at all and/or having largely contentless 'I agree!'-style messages clogging up the  timelines of their followers.[^2] The ability to send a range of reactions that are only visible to the person who sent the message is a compromise that preserves most of the benefits of the status quo while ameliorating its disadvantages.

* **Link Previews**: I understand why some people don't like them but I find Twitter's preview cards a helpful way to get a feel for a linked webpage and decide whether I want to read it or not. Neither Micro.blog itself, nor any of the third party clients of which I'm aware, offer something like this. Instead, you need to tap through to see what the actual page is like.[^3] That's particularly frustrating for slow-loading sites (of which there are, at least for me, many). Although this could be implemented on the server side, it's probably more appropriate to leave it to clients.

* **Extended Post Feeds**: One of the central ideas of Micro.blog is that, at the end of the day, everyone's account is just a blog. There are some downsides to that. I used to subscribe to Manton's blog in my RSS reader. However, once he moved to using Micro.blog to host it, that meant the blog's RSS feed included both his microposts and his  extended posts. That's great if you want to make sure you never miss anything by the person but I'd appreciate there being a link that just shows the extended posts.

* **Spoiler Tags**: One of the major elements of the Micro.blog discussion in the past week has involved comparisons between Micro.blog and [Mastodon][mos], a decentralised Twitter-like service that's got a lot of recent attention. Mastodon has some interesting ideas with the one that intrigues me the most being the ability to 'hide' messages behind a warning. People use this in all sorts of ways (for traditional media spoilers, for sensitive material, hot-button political discussion, etc) but I personally want it for basketball. I'm an NBA fan but live in Japan. Games are typically on in the late morning here and I don't have a chance to watch them until late at night. It's the off-season right now but once things kick off in October, I'm not looking forward to having to either unfollow people who talk in real time about games[^4] or just avoid Micro.blog entirely during the day.

* **Autocompleting Usernames**: It would make conversations on Micro.blog better if usernames autocompleted. This is particularly the case for replies. Another example of how Micro.blog differs from Twitter is that only the username of the writer of a post is included in a reply and not the other users that were mentioned in the reply (at least, this is the way that both the official clients and Icro work). I assume this is to reduce the prevalence of reply 'canoes' that you often see in Twitter threads between more than two people. That seems like a good choice but there are times when it makes sense to include another person and having your client autocomplete their name would be very helpful in such instances. Although this is something that would be implemented at the client-level, for it to work properly, my guess is there'd need to be an API that a client could query to check for potential matches.

Those are at the top of my list so far. I'm curious whether others are similarly interested.

[^1]: You and I both knew there would be some more ado. I have two points. First, the discussion about diversity and inclusiveness on Micro.blog is important. I don't want to belittle that. Second, some of these suggestions are really about how Micro.blog clients work. I've lumped them here together but have noted the distinction when it needs to be made.

[^2]: Supporters often counter that by saying that it's possible to toggle the visibility of replies of people you follow to people you don't follow. The problem is that I don't want an all-or-nothing approach. Micro.blog's 'visible replies' is the key way I find new people but it's typically when someone I follow writes a more fulsome message to someone. I want to see those, just not short reaction messages.

[^3]: The problem is frustratingly most noticeable for extended posts to Micro.blog itself. These appear in the timeline with _only_ a title and absolutely nothing else to give you a hint what the actual post itself will be like.

[^4]: At the risk of looking like a Manton Reece stalker given how almost every bullet point has so far mentioned him, I hesitate to use as an example, Manton Reece.

[nyta]: https://www.nytimes.com/2018/08/10/technology/twitter-free-speech-infowars.html

[mra]: http://manton.micro.blog/2018/05/18/twitter-streaming-api.html

[mos]: https://joinmastodon.org/

