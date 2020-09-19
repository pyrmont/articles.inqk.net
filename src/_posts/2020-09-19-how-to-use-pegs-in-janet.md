---
title: "How-To: Using PEGs in Janet"
layout: post
date: 2020-09-19 10:10:37 +0900
excerpt: "Instructions on how to use parser expression grammars in Janet."
category: 
tags: 
---

Janet is a small, Lisp-like language. Unlike most programming languages, it
offers no support for regular expressions. Instead, Janet supports parser
expression grammars, or PEGs.

A PEG in Janet is usually described by an associative data structure that lists
a series of rules.[^1] For each rule, the key is the name of the rule and the
value is a description of the string that the rule will match. What makes PEGs
especially powerful is the ability for rules to refer to other rules (including
recursive references) and for rules to run arbitrary functions.

Let's see how we can use a PEG to parse a simplified subset of HTML. We'll use
sequences, choices, captures (both compiled and match-time), replacements,
drops and back-references. It's going to be fun.[^2]

## Steps

### Step 1. Define `:main` rule

Janet begins parsing using the `:main` rule. So let's start with that:

```janet
'{:main (* :tagged -1)}
```

This rule defines a pattern consisting of a sequence (represented by `*`)[^3] of
the rule `:tagged` and the value `-1`. This rule will match if the rule
`:tagged` matches and then the string ends (the value `-1` matches if we are at
the end of the string).

### Step 2. Define `:tagged` rule

Now if we try to use this grammar, Janet will complain that the rule `:tagged`
is not defined so let's define that next:

```janet
'{:main (* :tagged -1)
  :tagged (* :open-tag :value :close-tag)}
```

This is pretty straightforward. Our `:tagged` rule consists of an opening tag,
a value of some kind and a closing tag.

### Step 3. Define `:open-tag` rule

```janet
'{:main (* :tagged -1)
  :tagged (* :open-tag :value :close-tag)
  :open-tag (* "<" (capture :w+ :tag-name) ">")}
```

We name the capture so that we can use a reference to it in our closing tag
rule. I went with `:tag-name` but you can choose whatever you like.

### Step 4. Define `:close-tag` rule

Up to this point, we've been adding rules in the order that they're processed.
Let's deviate from that here and instead define our next rule to match closing
tags:

```janet
~{:main (* :tagged -1)
  :tagged (* :open-tag :value :close-tag)
  :open-tag (* "<" (capture :w+ :tag-name) ">")
  :close-tag (* "</" (cmt (* (backref :tag-name) (capture :w+)) ,=) ">")}
```

This rule can be a little difficult to follow. We're doing a match-time capture
here using the `cmt` function.[^4] This will match if the result of the provided
function (in this case, `=`) is truthy. If it is falsey, the match will fail.

The `=` function is passed the values of any captures as separate arguments. We
have two captures in our pattern: the back-reference to the `:tag-name` capture
and the value matched by `:w+`. If the tag names match,[^5] the `:close-tag`
rule will match.

The eagle-eyed amongst you might have noticed that the quoting character at the
very beginning has changed from `'` to `~`. All but the simplest PEGs will
include references to various functions `sequence`, `capture`, etc that are run
by the PEG engine. To prevent these functions being called in our grammar
definition, we need to quote our data structure. However, when it comes to
passing the functions we want `cmt` to call, we need to pass a reference to
these functions. The solution is quasi-quoting. We quasi-quote the data
structure and then unquote the function symbol.

### Step 5. Define `:value` rule

OK, now we'll define the `:value` rule:

```janet
~{:main (* :tagged -1)
  :tagged (* :open-tag :value :close-tag)
  :open-tag (* "<" (capture :w+ :tag-name) ">")
  :value (any (+ :tagged :untagged))
  :close-tag (* "</" (cmt (* (backref :tag-name) (capture :w+)) ,=) ">")}
```

The value in between two tags could be nothing, a tagged value, an untagged
value or a combination of tagged and untagged values. We can match zero or more
occurrences of the pattern using the `any` function. The `+` combinator[^6]
tries the first pattern (`:tagged`) and if that fails, tries the second pattern
(`:untagged`).

### Step 6. Define `:untagged` rule

Speaking of `:untagged`, this is the last named rule we need:

```janet
~{:main (* :tagged -1)
  :tagged (* :open-tag :value :close-tag)
  :open-tag (* "<" (capture :w+ :tag-name) ">")
  :value (any (+ :tagged :untagged))
  :close-tag (* "</" (cmt (* (backref :tag-name) (capture :w+)) ,=) ">")
  :untagged (some (if-not "<" 1))}
```

This rule matches against one or more characters that are not `<`.

### Step 7. Drop back reference after use

We have a problem at the moment. Our grammar won't match nested tags because the
`:tag-name` capture is never being removed from the capture stack. We can solve
this problem using `drop`:

```janet
~{:main (* :tagged -1)
  :tagged (drop (* :open-tag :value :close-tag))
  :open-tag (* "<" (capture :w+ :tag-name) ">")
  :value (any (+ :tagged :untagged))
  :close-tag (* "</" (cmt (* (backref :tag-name) (capture :w+)) ,=) ">")
  :untagged (some (if-not "<" 1))}
```

Now when we get to the end of a nested `:tagged` pattern, we'll drop the captures.

### Step 8. Capture tag names and values

The above is all well and good for checking if a string matches the grammar but
it's usually much more helpful to return some structured data. Let's do that:

```janet
~{:main (* :tagged -1)
  :tagged (replace (* :open-tag :value :close-tag) ,struct)
  :open-tag (* (constant :tag) "<" (capture :w+ :tag-name) ">")
  :value (* (constant :value) (group (any (+ :tagged :untagged)))
  :close-tag (drop (* "</" (cmt (* (backref :tag-name) (capture :w+)) ,=) ">"))
  :untagged (capture (some (if-not "<" 1)))}
```

There's quite a bit going on here so let's look at each rule in turn.

1. We've replaced our call to `drop` with a call to `replace`. This will pop
   the captures matched by `(* :open-tag :value :close-tag)` but instead of
   dropping them, will pass them to the function `struct`. We'll see why in a
   second.

2. Next, in `:open-tag`, we're pushing the value `:tag` onto the capture stack
   using `constant`. Because the call to `constant` is part of the sequence in
   this pattern, it only occurs if the entirety of the pattern matches.

3. We use a similar trick in `:value`. This time, instead of pushing `:tag`, we
   push `:value`.

4. Still in `:value`, we use `group` to collect all of the matches in the `(any
   (+ :tagged :untagged))` pattern and put them inside an array that we push
   onto the capture stack.

5. Next, we've added a call to `drop` in `:close-tag`. This ensures that the
   value generated by the function `=` (i.e. `true`) is removed from the
   capture stack.

6. Finally, we need to capture the result of `:untagged`. We do this with
   `capture`.

Now the call to `struct` hopefully makes sense. At the time this is called, the
pattern always returns four captures: (1) `:tag`, (2) the tag name, (3)
`:value` and (4) the tag's value. These get pulled off the capture stack,
turned into a struct and pushed back on.

### Bonus Step. Compile the grammar

If we intend to use the grammar repeatedly, we can compile it for a performance
boost:

```janet
(peg/compile
  ~{:main (* :tagged -1)
    :tagged (replace (* :open-tag :value :close-tag) ,struct)
    :open-tag (* (constant :tag) "<" (capture :w+ :tag-name) ">")
    :value (* (constant :value) (group (any (+ :tagged :untagged)))
    :close-tag (drop (* "</" (cmt (* (backref :tag-name) (capture :w+)) ,=) ">"))
    :untagged (capture (some (if-not "<" 1)))})
```

## Example

Let's see an example. Assuming this is our code:

```janet
(def grammar
  (peg/compile
    ~{:main (* :tagged -1)
      :tagged (replace (* :open-tag :value :close-tag) ,struct)
      :open-tag (* (constant :tag) "<" (capture :w+ :tag-name) ">")
      :value (* (constant :value) (group (any (+ :tagged :untagged)))
      :close-tag (drop (* "</" (cmt (* (backref :tag-name) (capture :w+)) ,=) ">"))
      :untagged (capture (some (if-not "<" 1)))}))
```

Then:

```janet
(peg/match grammar "<p><em>Hello</em> <strong>world</strong>!</p>")

# => @[{:tag "p"
#       :value @[{:tag "em" :value @["Hello"]}
#                " "
#                {:tag "strong" :value @["world"]}
#                "!"]}]

(peg/match grammar "<em>Hello</em> <strong>world</strong>!</p>")

# => nil
```

The second match returns `nil` because of the unmatched `</p>`. Neat!

## Wrap-Up

Building support for PEGs directly into the language is one of Janet's best
decisions. They might take a bit of time to get the hang of, but when you do,
you'll be able to parse data in a way that's considerably more powerful than
with regular expressions.

[^1]: It is possible to define a PEG using a string that contains a single
  (unnamed) rule but that's not especially interesting so we'll focus instead
  on the associative definition.

[^2]: I have barely left my house in the past six months.

[^3]: To make the other functions stand out, I'm using the alias `*` rather
  than `sequence` in this post.

[^4]: Match-time captures are created using the `cmt` function. It's
  unfortunate that this function looks like it's related to commenting. Really,
  the `cmt` function is a way of dynamically adjusting a pattern using
  captures.

[^5]: This comparison is case _sensitive_. If you want a case-insensitive
  match, you need a different function to `=`.

[^6]: As with `*`, we are using the alias `+` rather than `choice`.
