---
title: Feedback on Sunlit 2.0 Beta
layout: post
date: 2018-02-05 17:19:15 +0900
category:
tags: []
---

# Feedback on Sunlit 2.0 Beta

_Sunlit 2.0[^1] is currently in beta. Since one of the developers is [Manton Reece][mr],[^2] I thought I'd write my feedback up in the form of a blog post._

[mr]: https://manton.org/

_One could read this as me being a lot more aggreived than I actually am. Indeed, I’m not aggrieved at all; I’m delighted Manton and Jonathan are working on Sunlit! My strong feelings come from a place of deep excitement about what Sunlit could be._

## My Use Case

Feedback is provided below, but explaining how I want to use Sunlit will, I think, make that feedback more constructive.

### Wants

I want:

* an app that will allow me to post both one-off photos and collections of photos to a website on my own domain;
* the resulting website to be separate to other websites I may have and for it to function like a blog (reverse chronological order home page, individual pages for each posts, syndication feeds, etc);
* the resulting website to be static files that can be managed through Git.

### Would Likes

I would like:

* for the app to have some social component, so that I could discover other people’s photos and have (at least some) of my photos be easily discoverable;
* to be able to post certain collections to ‘secret’ pages that are only visible by going to the specific (and quasi-random) URL.[^3]

## Feedback

Sunlit is the closest thing I’ve found to my ideal photo sharing app. I’m extremely excited about it. That said, there are some issues with how it currently functions that (sometimes severely) limit its usefulness.

### Multiple Microblogs

The biggest problem I have is how Sunlit works with Micro.blog. Micro.blog is one of the publishing endpoints you can select and this is a large part of the appeal for me (two of my three wants relate to the resulting website, not the actual app). Because I like compartmentalising, I want to separate the microblog I use as [my Twitter replacement][uiq], from the microblog I want to use as [my Instagram/Flickr replacement][oiq].[^4]

[uiq]: https://updates.inqk.net
[oiq]: http://outings.inqk.net

Unfortunately, although it’s possible to have multiple microblogs associated with a single Micro.blog account,[^5] Sunlit can only publish to the particular microblog you _currently have set as the default on the Micro.blog website_. There is no way to change the default microblog, either in Sunlit or in the native Micro.blog apps.

The expectation that you will have only one microblog associated with your Micro.blog account causes problems in other areas. When you first link Sunlit to your Micro.blog account, it will use your default microblog as the registered endpoint. However, it will continue to display this as the endpoint even if you change the default on the Micro.blog website (the microblog used is always the one set as your default).

A similar problem arises when modifying an existing story (by either updating or deleting the story). If you’ve changed the default microblog after publishing a story then subsequent modifications will simply fail, with no indication what went wrong.

### Hosted Microblogs Themes

Part of the promise of Sunlit (at least as I perceive it) is as the do-it-all photo sharing app. In theory, it could do both Instagram-like one-shots  and Flickr-like galleries. You could imagine these displaying the same way that some Micro.blog users display their posts on their blogs: titleless updates for short posts and more full-on articles for longer posts (see examples [here][mr] and [here][mm]).

[mm]: https://mmarfil.com

Unfortunately, the present reality is a little removed from this. I’m currently using the Cactus theme and it doesn’t display photos on the index page at all. This is fine so long as your pictures has a title but if they don’t, then while they’re [there][oiqs], they’re not really [there][oiq].

[oiqs]: http://outings.inqk.net/2018/02/05/031649.html

A [recent update][rum] to Micro.blog improved the themes available for hosted microblogs but they remain ill-suited for Sunlit. And since Micro.blog doesn’t allow for custom themes, there’s not much you can do about this but grin and bear it.

[rum]: http://www.manton.org/2018/01/micro-blog-theme-updates.html

On the one hand, I can understand if Manton and Jonathan’s attitude is that since the entire ethos of Micro.blog is about owning your own content, relying on Micro.blog to provide all this stuff is somewhat counterproductive. I can have all the customisation I want if I run my own microblog or simply set up a WordPress installation. I see the logic to this argument, but I have two counterpoints: (1) providing this kind of turn-key solution is a great way to encourage people to pay Micro.blog money; and (2) all of the self-hosted solutions I’ve looked at so far are varying degrees of gross.

### Location, Location, Location?

One of the unique ideas in Sunlit is allowing ‘check-ins’ to be associated with a story. A story can then consist of text, photos and maps. There are two disappointing limitations to this at present.

The first is the nature of the map itself. Choosing a location (more on that below) results in an image of your location being added to the story. This seems like a missed opportunity to take advantage of the very fact Sunlit exports webpages and so can drag in a fully functioning map (be that from Google, MapBox or whomever).

The second is with the very way you add a location. As things currently stand, you can only add a location based on where you literally are at the moment you’re creating the story or from your Swarm check-in history (and even then, only to a particular point in time—I couldn’t work out how far back it searched but it definitely wasn’t my entire Swarm check-in history)

Why this limitation? Why can’t I choose any location? Why not at least look at the location data embedded in the photos? It seems reasonable that people will use Sunlit after they’ve returned from a trip (or at the very least, gone back to their hotel). Unless you use Swarm and remember to check in from where you took the photo, the locations you’ll be able to add won’t be much help.

### The Discover Tab

The key difference between version 1 and version 2 of Sunlit is the way that Micro.blog allows for a social network to be layered onto the app. This is primarily exposed through the Discover tab, which shows a grid of photos people have posted to Micro.blog (regardless of whether those photos were sent through Sunlit or not).

This is an interesting decision and potentially makes Sunlit much more of an app you’d regularly want to check. Unfortunately, the experience so far isn’t super great. If you want to view the photos in a timeline kind of way (a la Instagram), you can do that but the presentation is pretty… rough.

For example, there’s no way to tell if photos in Discover are one-shots or galleries so if you’re wondering if something is merely the first in a series, you have to go tapping on the photo just to see.

More significantly, the actual social interactions are strangely limited. There is no way to interact with any of the photos directly. All you can do is open the photo in an in-app browser. Even then, you still can’t interact with the content easily. When you tap on a photo, you move to a light box mode where you see the URL to the photo and a link to open in the Micro.blog app. You might think that tapping on the Micro.blog app would open the post in Micro.blog. It does not. Instead, it opens the profile for that user. You have to scroll through their timeline to try to find the particular photo if you want to interact with it. Alternatively, you can tap on the link but since that takes you to the URL of the actual webpage, none of the Micro.blog social features (favouriting, replying) are available there.

Manton’s been careful in building out Micro.blog not just to ape features of Twitter. I assume Manton and Jonathan are thinking along similar lines here (replace ‘Twitter’ with ‘Instagram’). The difference is that I feel Micro.blog has a baseline that provides a minimum viable level; it feels less that way with Sunlit.

### Miscellanney

Finally, some minor points. No doubt some of these are merely the result of the app being in beta but I note them for completeness nevertheless.

* You bizarrely can’t take a photo _in_ Sunlit. This is despite the location limitation mentioned above.
* When you publish a story, a link to the individual post is displayed. If you tap the link, you’re presented with iOS’s action/share sheet. There’s no way to simply open the link in Safari. You need to tap the link, tap copy, open Safari, paste the link.
* If you don’t provide a description for a story involving multiple posts, most themes will display raw dates. Short of possible CSS tomfoolery, there’s no way to customise the output of these dates.
* If you delete a story with no title, the modal dialog box says, ‘The story “” will be deleted from your phone.’

## Conclusion

As I hopefull made clear at the beginning, I really want Sunlit to be great. I think Manton and Jonathan have the germ of something terrific here that will, when fully realised, increase the value people can derive from Micro.blog. I'm greatly looking forward to watching it evolve.

[^1]: At the centre of the app is its concept of the ‘story’. A story is essentially a blog post. It’s a unit of ‘content’, which can be published ‘somewhere’ (at present: a microblog, a WordPress installation, Flickr, Instagram and Dropbox). A story can contain photos, locations and text. The photos in a story are grouped by date, with the intention being that you will create a story for a trip and that the sections of the story will be broken up by day. That said, there’s nothing to stop a trip having a single photo or to use multiple stories to share photos that occurred on the same trip.

[^2]: In [an earlier version][aev] of this article, I said I wasn't sure if Jonathan Hays, the other half of the original development team, was still working on Sunlit. [He very much is][mfm]. I've made adjustments to the text to reflect this.

[aev]: https://github.com/pyrmont/articles/commits/master/_posts/2018-02-05-sunlit-feedback.md
[mfm]: https://micro.blog/manton/316365

[^3]: Since this is an additional feature, rather than feedback on Sunlit's existing feature set, I don't discuss it any further in this article. But it would be cool.

[^4]: I have to pay for these microblogs separately. This is not a disincentive to me but I can imagine it is to a lot of people. Since my biggest issue with Sunlit arises from using Micro.blog like this, I’m sympathetic if Manton and Jonathan consider supporting this workflow a low priority (even if it does make me more valuable on an individual customer basis!).

[^5]:
    The fact you can use the term ‘Micro.blog’ to describe both the overarching Micro.blog service as well as a website that conforms to the requirements to be an endpoint for Micro.blog is one of the most confusing elements of the entire thing. I understand how it works but I had to literally email Manton to check I had it correctly.

    It’s even more complicated than it appears at first blush  because there are actually three parts: (1) Micro.blog, the social network; (2) a Micro.blog-compatible blog hosted on Micro.blog; and (3) a Micro.blog-compatible blog not hosted on Micro.blog.

    For the purposes of this article, I’ll use the term Micro.blog to refer to the social network and microblog to refer to a conforming website (whether hosted on Micro.blog or not).

