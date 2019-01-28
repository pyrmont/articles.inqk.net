---
title: "What is `let*`?"
layout: post
date: 2019-01-22 14:18:24 +0900
excerpt: "An investigation into the difference between `let` and `let*` in Clojure."
category: 
tags: 
---

## The Problem

In [Chapter 8][ch8] of Daniel Higginbotham's very good book, _Clojure for the Brave and True_, we define the macro `if-valid`. I won't go into much detail about the context except to say that the macro involves the use of `let`.

[ch8]: https://www.braveclojure.com/writing-macros/

Later in the chapter, we're directed to use the function `macroexpand` to expand the `if-valid` macro. Here's the relevant code listing:[^1]

```clj
(macroexpand
 '(if-valid order-details order-details-validations my-error-name#
            (println :success)
            (println :failure my-error-name#)))
; => (let*
; => [my-error-name__3737__auto (user/validate order-details order-details-validations)]
; => (if (clojure.core/empty? my-error-name__3737__auto)
; =>  (println :success)
; =>  (println :failure my-error-name__3737__auto)))
```

Wait, `let*`? What's that? That's not what we wrote. What's going on here?

## Special Forms

One of the most elegant aspects of Lisp is that it can be implemented using a very small number of special forms.[^2] One of the ones that Clojure uses is commonly said to be `let`.

The thing is `let` isn't a special form.[^3] Indeed, typing `(doc let)` into a REPL will tell you that `let` is in fact a macro. If you run `(source let)`, you'll be presented with the following:

```clj
(defmacro let                                                               
  "binding => binding-form init-expr                                        
                                                                            
  Evaluates the exprs in a lexical context in which the symbols in          
  the binding-forms are bound to their respective init-exprs or parts       
  therein."                                                                 
  {:added "1.0", :special-form true, :forms '[(let [bindings*] exprs*)]}    
  [bindings & body]                                                         
  (assert-args                                                              
     (vector? bindings) "a vector for its binding"                          
     (even? (count bindings)) "an even number of forms in binding vector")  
  `(let* ~(destructure bindings) ~@body))      
```

There's our friend `let*`. What's it doing there? Unfortunately, `(doc let*)` and `(source let*)` return nothing. Fortunately, as [this Stack Overflow answer notes][so-ll], a hint about what's really going on can be found in the Clojure source code.

[so-ll]: https://stackoverflow.com/a/31661863/308909

## Because Destructuring

Clojure provides a number of conveniences in comparison with other Lisps. One of these conveniences is argument destructuring. Argument destructuring allows us to write more concise and expressive code.

Imagine we have an vector `z` that consists of two elements. We'd like to bind the first element to the symbol `x` and the second element to the symbol `y`. Without destructuring, we'd need to write something like `let [x (first z) y (second z)]`. _With_ argument destructuring, we can instead write `let [[x y] z]`.

The problem is that, as [the comment in the Clojure source alludes to][gh-cc], we don't have access to the function `destructure` when we're bootstrapping the code.[^4] That means we can't use destructuring in special forms directly. But what about indirectly? We could define the special form using a variation on the name we actually want to use (eg. `let*`) and then define a macro with the name we want to expose (eg. `let`). Woo!

[gh-cc]: https://github.com/clojure/clojure/blob/ee3553362de9bc3bfd18d4b0b3381e3483c2a34c/src/clj/clojure/core.clj#L31

## The Answer

The use of `let*` as the 'real' special form is evident when we consider [the Java code for the Clojure compiler][gh-jc]. That code defines the various special operators we have in Clojure. Our good friend `def` is there, as is `if` and `quote`. But special forms that use destructuring aren't. Instead, they're replaced with their starry-eyed cousins. It's `let*` instead of `let`, `loop*` instead of `loop`, `fn*` instead of `fn` and so on.

[gh-jc]: https://github.com/clojure/clojure/blob/2cc37bb56a9125a1829c73c505e32995e663059a/src/jvm/clojure/lang/Compiler.java#L44

So back to our original problem: why did `macroexpand` output `let*`? Now that we understand how `let` is implemented, the docs for `macroexpand` provide the answer.

```clj
(doc macroexpand)
; => -------------------------                                                   
; => clojure.core/macroexpand                                                    
; => ([form])                                                                    
; =>  Repeatedly calls macroexpand-1 on form until it no longer                 
; =>  represents a macro form, then returns it.  Note neither  
; =>  macroexpand-1 nor macroexpand expand macros in subforms.
```

`macroexpand` is repeatedly expanding the macros in `if-valid`. That includes not only the `if-valid` macro, but the `let` macro we unwittingly included within it. And that results in the output including `let*`.

## Conclusion

Some of the 'special forms' that Clojure provides are really macros that are implemented in terms of the 'real' special forms. Most of the time, you'll never notice the difference but occasionally (such as when expanding macros), these implementations will leak through. Fear not, you're just improving your understanding of how Clojure works!

[^1]:
    OK, so strap yourself in because this one's long.

    First, there's a mistake in the code listing in Chapter 8 that shows the output from `macroexpand` as being code to be input. Higginbotham follows the common documentation practice of showing the output of evaluated code as a comment; however, the Chapter 8 listing mistakenly omits this. This has been corrected in the code listing in this post.

    Second, in Clojure 1.10.0, the compiler will throw an error if you try to input the code as written in Chapter 8. This is because `macroexpand` is now subject to a spec that prevents the use of simple symbols (such as `my-error-name`). These symbols [must be appended by a `#`][cljd] so that a unique unqualified symbol will be generated. This has also been corrected (and an example generated symbol is used in the output).

    [cljd]: https://clojure.org/guides/weird_characters

    Third, when I run the code with Clojure 1.10.0, my output fully qualifies all of the symbols. That is, rather than `(println :success)`, I see `(clojure.core/println :success)`. For legibility reasons, I've left this out of the output but if you see the same thing, don't freak out.

    Phew.

[^2]:
    Geez, this is becoming a thing, isn't it?

    So, first, some terminology. When discussing the basic building blocks of Lisps, there's a tendency online to loosely throw around the terms primitives, special operators and special forms. As I understand things, technically (a) **primitives** refers to elements of the language like numbers, strings, symbols, booleans, etc; (b) **special operators** refers to special symbols (eg. `def`) that are treated differently to other symbols; and (c) **special forms** refers to expressions that have as their operator a special operator (eg. `(def x true)`).

    Now, in this post, I tend to follow the dominant pattern in the Clojure community and refer to both special operators _and_ special forms as 'special forms'. Confusing, I know.

    As for the minimum number of special forms that are necessary to implement a Lisp, the specific number depends to some degree on how convenient you want to make the language. [Somewhere between five and ten ][so-sf]seems to be the rough minimum.

    [so-sf]: https://stackoverflow.com/q/3482389/308909

[^3]: Clojure's documentation says that it _is_ a special form so who am I to say this? I'm a guy on the Internet. Fight me.

[^4]: This is beyond my understanding at the moment but presumably it would be possible to define a Lisp where `destructure` is itself a special form. I'd guess that Clojure doesn't do that because you can achieve the desired effect with macros and doing so allows for the number of special forms to remain small.