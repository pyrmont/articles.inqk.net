---
title: "Embracing Parentheses"
layout: post
date: 2019-01-15 17:04:03 +0900
excerpt: "A plea to stop pretending parentheses in Lisps aren't a thing."
category: 
tags: 
---

As part of my Clojure education, I've been watching a _lot_ of talks on YouTube about Clojure. One thing I've seen numerous speakers do when introducing Clojure is to try to convince the audience that the perception that Lisps are drowning in parentheses is mistaken (or at least mistaken in respect of Clojure).

These speakers look nuts whenever they do this and I'd urge anyone preparing a talk where they'll be doing the same to stop.

The most common method to encourage the audience to not believe their lying eyes is to count the number of parentheses in a piece of Clojure code and compare it with the number of parentheses in a piece of non-Lisp code.[^1] Apart from sounding like a weird reverse dick-measuring contest, the central problem with doing this is that it misunderstands the aversion.

The reason that parentheses are off-putting is that they make the code more difficult to read and write. However, this isn't because of their quantity. As the comparisons seek to demonstrate, non-Lisps may contain the same number of parentheses. So why don't programmers have issues with non-Lisps? It's because the difficulty is due to the placement of the opening and closing parentheses relative to each other. Non-Lisps will locate their parentheses relatively close to each other (in the most extreme case of an expression like `some_function()` they are literally side by side).

In contrast, Lisps put the entire expression in parentheses. This necessarily means that the parentheses will be at least as far apart as they'd be in any other language. This problem is exacerbated by the fact that the nested function calls encouraged by Lisps leads to the situation where an expression can end with several (if not more) collocated closed parentheses.

The better approach would be to embrace the parenthesis. In the same way that Haskell programmers champion functional purity as a virtue, Clojurists should explain why [having your code be expressed in the form of a native data structure][mcp] is an overall positive. Such an explanation can—and I'd argue should—involve an acknowledgement of the fact that nesting parentheses are an issue but then quickly turn to the benefits this syntax brings (mention can also be made of the various tools that are available to greatly minimise this as an actual day-to-day problem).

I've come to Clojure from Ruby, a language which is about as opposed to parentheses as you can be. If I can be convinced to embrace the parenthesis, I'm confident others can, too.

[mcp]: http://articles.inqk.net/2019/01/11/code-as-data-structures.html

[^1]: These comparisons are almost always heavily rigged in favour of Clojure. Speakers avoid common language constructs like `let` where Clojure clearly uses more parentheses, they choose a particularly verbose language like Java as a comparison and, occasionally, they'll attempt to include the number of braces and square brackets. The latter technique looks particularly desperate.