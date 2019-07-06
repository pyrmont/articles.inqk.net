---
title: "Code is Data (Structures)"
layout: post
date: 2019-01-11 11:09:36 +0900
excerpt: "An attempted explication by a Clojure beginner on the meaning of the phrase 'code is data'."
category: 
tags: 
---

I started learning Clojure in December[^1] and one of the refrains I kept hearing people say was 'code is data'.

While pithy, I found this bordered on meaningless. What's code? Any code? Clojure code specifically? What's data? Information? Information encoded in the program? If code means the instructions in the program and data means, well, data, isn't all code data? How is Lisp different from Ruby or Python or any non-Lisp language in this respect? I couldn't make any sense of it.

Things clicked into place for me when I realised there was a word missing. It lacks the punch of the original but, to my mind, a more accurate aphorism would be 'code is data structures'.

Before explaining that more, let's remind ourselves what a data structure is. In Clojure, the three most common data structure are the list, the vector and the map. Each data structure is expressible in a literal syntax that uses a different type of bracket:

- The **list** uses Lisp's infamous parentheses. A simple list of the numerals 1, 2 and 3 might look like `(1 2 3)`.

- The **vector** uses square brackets. A simple vector of the numerals 1, 2 and 3 might look like `[1 2 3]`.

- The **map** uses braces. Unlike lists and vectors, the reference to each value in the map is explicit. References and values are written as reference-value pairs in Clojure's literal syntax. A simple map of the numerals 1, 2 and 3 might look like `{:one 1 :two 2 :three 3}`.

Now that we're familiar with these basic data structures and how they can be expressed directly, let's look at some more data structures.

Consider this one:

```clojure
(+ 1 2 3)
```

Here we have a list with four elements. First, we have the plus sign followed by the numerals 1, 2 and 3.

Here's a slightly more complex one:

```clojure
(defn eg [] (+ 1 2 3))
```

This is a list of four elements, `defn`, `eg`, the empty vector and the same list we had above. Of course, the surprise reveal is that these data structure are also valid Clojure code.

The first is an expression consisting of the symbol `+` with the arguments 1, 2 and 3. When we ask Clojure to evaluate this expression it will use the first element to look up the name of the function and then pass the numerals 1, 2 and 3 as arguments to that function. The value returned from the evaluation is 6.

The second is an expression that, although more complex, is evaluated similarly by Clojure. The symbol `defn`  is actually the name of a function and the other elements are passed to that function as arguments. The evaluation step saves a reference to this function in the state of our program that we can call again later.

Now we can see how 'code is data (structures)' applies to Clojure in a way it doesn't to Ruby.

```ruby
def eg()
  1 + 2 + 3
end
```

This code does the same thing as the call to `defn` did above but it is not a data structure.

Having our code be expressed as data structures is conceptually elegant but it also allows for powerful features like macros that either aren't possible, or are nowhere near as flexible, as they are in a Lisp. That's a topic I hope to return to in the future but let's leave it there for now. Happy hacking!

[^1]: Since that means I've been doing this for all of a month there's a good chance I've made some mistakes in the details. Corrections welcome on [Twitter][twp] or [Micro.blog][mbp]!

[twp]: https://twitter.com/pyrmont

[mbp]: https://micro.blog/pyrmont