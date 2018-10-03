---
title: "How-To: Push to a Git Repo from 1Writer"
layout: post
date: 2018-10-03 08:19:05 +0900
excerpt: "Instructions on how to configure 1Writer to push to a Git repository."
category: 
tags: 
---

One of the things that got me blogging again was finding a workflow that enabled me to publish posts to Jekyll from my phone.[^1] I intend to write a larger how-to explaining that process in detail but, for the purposes of this article, let's look at how we can take a text file from 1Writer and push it to a remote Git repository.

## Steps

### Step 1. Get the Tools

First, let's introduce the software:

- [1Writer][1writer] is a scriptable text editor for iOS. It supports the `x-callback-url` protocol and can execute user-defined 'actions' (scripts written in JavaScript). It's [available on the App Store][as1w] for a one-time purchase of $4.99.

[1writer]: http://1writerapp.com/

[as1w]: https://itunes.apple.com/us/app/1writer-markdown-text-editor/id680469088

- [Working Copy][wc] is a full-featured Git client for iOS. It supports the `x-callback-url` protocol. It's [available on the App Store][aswc] as a free download with an in-app purchase of $15.99 to unlock its pro features.

[wc]: https://workingcopyapp.com/

[aswc]: https://itunes.apple.com/us/app/working-copy/id896694807

I'll be using GitHub as the repository hosting provider but feel free to switch that out for your preferred host.

### Step 2. Configure Working Copy

Once you've got the apps, you need to connect Working Copy to your remote repository. From the main 'Repositories' screen, tap the `+` button in the top-right and choose 'Clone Repository'. Follow the steps and clone the repository onto your iOS device.

### Step 3. Collect Necessary Information

In order for 1Writer to 'talk' to Working Copy, we need to collect three pieces of information:

1. the **URL key**;
2. the **repository name**;
3. the **directory path** where we'll be exporting our text files.

The URL key can be found by opening Working Copy, tapping on the 'gear' icon in the top left from the 'Repositories' screen, tapping 'App Integrations' and noting the key listed.

The repository name is, as you might expect, the name of the repository. If you've cloned a GitHub repository as I did, by default it will be the name of the repo on GitHub.

The directory path is the path where you want to export your text files. If you're exporting to a Jekyll repository as I am, it'll probably be `_posts`.

### Step 4. Add the Action to 1Writer

To add an action to 1Writer, start a text file, hide the keyboard and then tap the three-dot widget in the bottom-left of the screen. 

This opens the 'Action' screen. In the top-right, tapping the `+` button will open a menu with three options; one of which is 'Add a JavaScript Action'. Tap this.

You can give your action whatever name you like. I call mine 'Publish Article' but you might prefer something more literal like 'Push to Repo'. You can choose an icon or leave it as the default. Similarly, you can provide an explanation of the action if you wish. All of these elements can be edited later.

Next, tap 'Edit Script'. This will open the script editor. Now it's time to copy and paste.

```javascript
// Main Steps

const key = '<YOUR KEY>'
const repo = '<YOUR REPO>'
const dir = '<YOUR PATH>/'

process(key, repo, dir)

// Function Definitions

async function process(key_name, repo_name, dir_name) {
  let key = key_name
  let repo = repo_name
  let path = dir_name + editor.getFileName()
  let text = editor.getText()
  let message = await input_message()

  key = encodeURIComponent(key)
  repo = encodeURIComponent(repo)
  path = encodeURIComponent(path)
  text = encodeURIComponent(text)
  message = encodeURIComponent(message)

  const url = `working-copy://x-callback-url/chain?key=${key}&repo=${repo}&command=pull&command=write&path=${path}&text=${text}&command=commit&message=${message}&command=push&x-success=onewriter://return/`

  app.openURL(url)

  ui.alert('Article Published')
}

function input_message() {
  return new Promise(resolve => {
    ui.input('Commit Message', 'Add post', 'Enter the commit message', resolve)
  })
}
```

There are three things to note:

1. you need to insert the information you collected in step 3 into the placeholders at the beginning of the script;
2. your path **must** include the trailing slash at the end; and
3. you can customise the actions that Working Copy performs by editing the `url` variable.[^2]

At this point, you can either run the action (which you probably don't want to do right now) or close the editor. You can always go back and edit an action by opening the action menu and tapping the 'info' mark (the 'I' in a circle) to the right of the particular action.

## Wrap-Up

The steps are complete and now you can push a file to a remote repository with a single tap! Happy writing!

[^1]: That process originally involved Editorial but since it appears to no longer be under active development, I've switched to 1Writer.

[^2]: You might, for example, prefer that the action didn't actually push the change but merely committed it.