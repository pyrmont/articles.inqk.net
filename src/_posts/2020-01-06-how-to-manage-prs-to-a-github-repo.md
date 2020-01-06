---
title: "How-To: Manage PRs for a GitHub Repository"
layout: post
date: 2020-01-06 17:01:31 +0900
excerpt: "Instructions on how to better manage PRs using GitHub's Hub tool."
category: 
tags: 
---

In 2019, I became a maintainer of the popular syntax highlighting library, [Rouge][]. Until then, I'd had very limited experience using pull requests with open source projects on GitHub.[^1] It took me a while to develop a good workflow for reviewing PRs but what I think I've got now works well and since I see a lot of people on other open source projects doing things differently (and in my opinion worse),[^2] I wanted to write some tips I hoped might help others.

[Rouge]: https://github.com/rouge-ruby/rouge/ "Rouge: Official Repository"

If you take away nothing else, the most important thing I want to suggest is that you should **use squash and merge** to merge PRs into your main branch. I'll discuss this in more detail later.

OK, let the transfer of knowledge begin!

## Steps

### Step 1. Download hub

GitHub makes a command line tool called [Hub][] and the first thing you should do is get that. There are other ways of doing so but let's assume you're using Homebrew:

[Hub]: https://hub.github.com/ "Hub's Official Website"

```console
$ brew install hub
```

### Step 2. Clone the Repository

It's a good idea to clone the repository using Hub because if you're maintaining a project that's under a different account (as I am with Rouge), cloning the repo with Hub will set up an upstream remote URL for you.

```console
$ hub clone <owner>/<project>
```

### Step 3. Checkout a PR

OK, so you can of course do a code review entirely on the GitHub website but maybe you've got a failing test you want to explore or perhaps you just prefer to look at this kind of thing in your editor. Now this is the functionality that I'm not sure everyone knows is possible:

```console
$ hub pr checkout <PR number> <local branch name>
```

Pretty sweet, huh? You just checked out the code in the PR using only the PR's number.

By default, Hub will use the same branch name as the PR author but you don't want to litter your local repo with that kind of thing so my suggestion is the following:

```console
$ hub pr checkout <PR number> pr/<PR number>
```

I use the convention of beginning the branch name for the PRs I pull down with the prefix `pr/`. While you can have slashes in Git branch names, as [this StackOverflow answer][so] explains, you can't have a branch with just the prefix as its name (i.e. you can't have `foo` and `foo/bar`) so whichever name you choose for your prefix, make sure it's not one you want to use for a branch name.

[so]: https://stackoverflow.com/a/2527452/308909

### Step 4. Push Changes

This step is optional. If you've got changes you think should be made to the PR, you can of course suggest these to the author of the pull request through GitHub's web interface. That's a good approach if there's a lot to change but almost always the PR author will have given you write access to their fork[^3] so for simple changes, why delay things?

Hub has set things up for you so after making your changes, simply type:

```console
$ git push
```

Voila! You just pushed to the author's fork![^4] And look—the PR page on GitHub has automatically updated itself!

### Step 5. Squash and Merge Changes

You finally have the PR ready to merge. Now what do you do? Merge it in from the command line? Gross—no, don't do that. Use GitHub's interface[^5] and **squash and merge** the change with a nice clean commit message.[^6]

This has two advantages. First, it means that the PR's author will get proper credit for authoring the change. That's nice.

Second, it keeps the commit log in your master branch clean and readable. Every change relates back to a PR and since GitHub will automatically add the PR's number to the commit title (and link it in the web interface), it's easy for you or other users to look at the history of the commit's development.

## Wrap-Up

Hopefully, that's been helpful. If there's something that's unclear or if I've made a mistake, be the first to let me know!

[^1]: Truth be told, my experience is still very limited. This article is intended to set out what I think are some good practices but please get in touch if you think I'm wrong.

[^2]: Said with the humility that you naturally expect from any person writing on the Internet.

[^3]: GitHub enables this by default and most people don't turn it off.

[^4]: In situations where you want to rebase the PR code against subsequent changes to master, you can do that but you'll then need to force push. I like to post a message on the PR's page once I've done this just explaining what I've done and why since you're possibly going to make life difficult for the PR author when they pull these changes down to their local version of the repo.

[^5]: Unfortunately, Hub doesn't provide simple support for squashing and merging (see [this issue][hub-issue]) so we have to use the website.

[hub-issue]: https://github.com/github/hub/issues/1339

[^6]: Depending on your repository's settings, you may not have the option to squash and merge. GitHub has [a nice help article][ghh] about how to enable this feature.

[ghh]: https://help.github.com/en/github/administering-a-repository/configuring-commit-squashing-for-pull-requests "GitHub Help article about configuring commit squashing"