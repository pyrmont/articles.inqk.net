---
title: "A Correction about GitHub"
layout: post
date: 2018-06-05 13:24:37 +0900 
excerpt: A not very consequential correction to Stratechery's quick summary of GitHub.
category: 
tags: []
---

I'm a subscriber to Ben Thompson's Daily Update newsletter over at Stratechery. Thompson had [a thoughtful post][sta] (paywalled) about the acquisition of GitHub by Microsoft on Monday. I did have one small bone to pick with it:

[sta]: https://stratechery.com/2018/microsoft-to-buy-github-a-win-for-github-facebooks-data-sharing-deals-with-device-makers/

  > To quickly back up, and provide some context,
  > “Git” is a version control system nominally for files
  > of all types, but predominantly used by developers
  > to store their code. Git was created by Linus
  > Torvalds, the man behind Linux, and like Linux, it is
  > completely open source; any one of you could
  > download and install a Git repository on your
  > computer, or any server you control.
  >
  > The problem with running Git on your own
  > computer, though, is the same problem that comes
  > with storing files of any kind on your computer:
  > backup, access from other machines, and sharing
  > access with others (and that’s not even mentioning
  > Git’s quite fiddly nature in general). The solution to
  > this problem — that is, a problem of user
  > experience with a dash of network effects — was a
  > centralized server that ran Git on your behalf: that
  > is GitHub.

It doesn't materially impact Thompson's analysis but the above is a little muddled. I was going to e-mail him to offer a correction but then I thought it might be more useful to have this here for future reference.[^1]

Git is the overarching name for a collection of open source[^2] software utilities that enable a version control system called Git. Git has essentially become the default such system for software development.[^3] Put simply, Git works by comparing the files in a particular directory (and its subdirectories) against earlier versions of those file and saves the differences in a special directory called the repository.

Thompson identifies GitHub's appeal as solving a user experience problem for developers. This is true but the reasons Thompson gives are a little jumbled. Using GitHub doesn't obviate the need to run Git on your computer. What GitHub does is make it far easier to share code, both for humans and for computers.

It's easy to see how GitHub helps humans. Users who create an account on GitHub (like [mine][ghp]) can save repositories to GitHub using the ability of Git itself to send code to another computer. GitHub then creates a little website for that repository ([here's an example][ght]). If the repository is public, any user can visit the GitHub URL and browse the files. It's easy to take it for granted now but a huge part of the early appeal of GitHub was how beautiful these sites were. It's now table stakes for online code hosting but when GitHub first came on the scene it looked like a gorgeous sports car in a sea of Model Ts.

[ghp]: https://github.com/pyrmont/
[ght]: https://github.com/pyrmont/taipo

GitHub also helps computers, though, and it's here where it's arguably more impactful. One of the features that set Git apart from the successful version control systems that were around when it was first released was the fact it was decentralised. What this meant was that instead of having a central repository of all the code that users would save to, Git gave each user their own repository. Users could then share code to another repository by making a request. That made it far easier for large teams of programmers to work together. With a central repository, users need to have permission to access the repository and they need to be careful when saving their changes as they may conflict with the changes other users have independently made. This becomes a nightmare as the number of users increases.

The thing is, though, that centralisation is kind of handy. As Thompson says, centralisation allows for easier backups, it allows for easier synchronisation between different devices, it allows for easier sharing with others. And so despite (or perhaps _because of_) being built atop a technology that was all about decentralisation, GitHub become the most centralised code storage service the world has ever known.

[^1]: In addition, I assume Thompson's already been bombarded with emails about this and doesn't really need another.

[^2]: Git is open source but this fact is orthogonal to being able to 'install' a repository on any computer. It would be equally possible to do this if Git were closed source. Git being open source means it has the benefits of other popular open source software development tools: (1) broad compatibility with different operating systems and hardware architectures; and (2) robust and well-tested (but [not infallible][msa]) design.

[msa]: https://blogs.msdn.microsoft.com/devops/2018/05/29/announcing-the-may-2018-git-security-vulnerability/

[^3]: There are other version control systems. None have the public visibility of Git.

