---
title: "How-To: Back Up a Sleeping MacBook's Time Machine to an External Disk"
layout: post
date: 2019-05-06 10:35:42 +0900
excerpt: "Instructions on how to save a sleeping MacBook's Time Machine backups to an external disk."
category: 
tags: 
---

This article will only be relevant if you meet the following criteria:

- you have a MacBook;
- you plug in an external disk only when charging;
- you want to save Time Machine backups to the external disk;
- you have your Mac set up to accept `ssh` connections;
- you have another computer with `ssh` and `cron`.

If you match that description, or if you just like reading technical guides, enjoy!

## Steps

### Step 1. Back Up to Your Disk

The remaining steps expect a disk that's been set up for Time Machine. Open Time Machine, connect your disk and make your first backup. If you choose to protect your backup with a password, note that down.

### Step 2. Find Your Disk ID

Our automation strategy takes advantage of the fact that you can initiate a Time Machine backup from the command line but for that we need to know the unique identifier for your disk.

While your disk is still connected, open Terminal and type the following:

```sh
diskutil list
```

Make a note of the long identifier for your external disk. It will look something like `12345678-1234-1234-1234-12345678ABCD`.

### Step 3. Create the Shell Script

Save this script somewhere on your Mac:

```
#!/bin/bash

echo "Unlocking disk..."
diskutil coreStorage unlockVolume <disk_id> -passphrase "<passphrase>"

echo "Mounting disk..."
diskutil mount <disk_id> 

echo "Backing up disk..."
tmutil startbackup --auto --block

echo "Ejecting disk..."
diskutil eject <disk_id>
```

You can omit the passphrase option to the first `diskutil` command if you chose not to use a password.

We're now finished with the steps we'll do on the Mac.

### Step 4. Power Your External Disk

If you put your MacBook to sleep by closing the lid and plugging in a power cable, you'll find that macOS will not be able to mount a subsequently plugged in external disk if that disk is not separately powered in some way.

This doesn't mean you necessarily need an externally powered disk. I'm using a bus-powered USB disk but have it connected via a separately powered hub (which ensures the disk has power without needing to draw it from the Mac).

### Step 5. Create the `cron` Job

Now move to the second computer. I use a Raspberry Pi but you can use any computer as long as it has `ssh` and `cron`.

Type the following at a command line:

```sh
crontab -e
```

Add the following line to the end of your crontab file:

```
0 5 * * * ssh <hostname_of_your_mac>.local "/bin/sh <path_to_script>"
```

The `0 5 * * *` means the backup will start at 5 am everyday. You can choose a different time and frequency by following the [instructions here][aca].

[aca]: https://www.adminschoice.com/crontab-quick-reference

If you're using SSH keys, you need a slightly different command:[^1]

```
0 5 * * * . ~/.keychain/<keychain_file> && ssh <hostname_of_your_mac>.local "/bin/sh <path_to_script>"
```

That's it, you're done!

## Rationale

Some of you may be wondering, why would you want to do this when macOS can back up over a network connection? There are two reasons.

- First, while macOS does support using a network drive for Time Machine backups, [they are flaky as shit][mwa].
  
[mwa]: https://www.macworld.com/article/3170844/when-backups-go-bad-the-problem-with-using-network-drives-with-time-machine.html

- Second, should you ever want to restore from the backup, you don't want to be doing this over a network connection.

By using an external disk, you avoid these problems. It's not ideal and it would be preferable if Time Machine worked properly with network drives but this is unfortunately not one of the situations where 'it just works'.

[^1]: This assumes you're using a system running [`keychain`][kcp].

[kcp]: https://www.funtoo.org/Keychain
