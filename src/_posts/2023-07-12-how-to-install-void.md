---
title: "How-To: Installing Void Linux on a Raspberry Pi"
layout: post
date: 2023-07-12 14:58:02 +0900
excerpt: "Instructions on how to install Void Linux on a Raspberry Pi 3 Model B."
category:
tags:
---
This is a short tutorial for how to install Void Linux on a Raspberry Pi 3 Model B.

## Pre-Requisites

I used the following:

1. Raspberry Pi 3 Model B
2. 16GB microSD card
3. Monitor
4. Keyboard

Regarding the third and fourth items, we do want to get the Pi ready for SSH access as soon as possible but at the very beginning it's great to have direct access to the machine.

If you have a different model of Raspberry Pi, these instructions might still work but bear in mind that your mileage may vary.

## Steps

### Step 1. Download a live image

Void Linux makes [live images][rpi-images] available for Raspberry Pi devices. I downloaded the glibc version of the rpi-armv7l live image because I'm afraid of trying new things but if you live life on the edge try the musl version and let me know if the rest of this guide worked for you!

[rpi-images]: https://voidlinux.org/download/ "Download the Void Linux live images for Raspberry Pi devices"

### Step 2. Install the live image

Use whatever tool you prefer to install the live image onto your SD card. I went with [Etcher][].

[Etcher]: https://etcher.balena.io "The home page for Balena Etcher"

### Step 3. Boot the Raspberry Pi

Install the SD card into your Pi and start it up. If all goes well, you should find yourself at a login prompt. At the time of writing, the live image has a `root` user with password `voidlinux`.

### Step 4. Resize root partition

The live image contains two partitions: a boot partition and the root partition. The bad news is that the root partition is only 2GB. The good news is that we can resize it from within Void.[^size] Normally, it's not advisable to resize a partition while you're using it, but since the root partition comes at the 'end' of the partition table, we can safely extend it into the remaining space without any issues.

We'll resize with sfdisk so let's start it up. We need to pass `--force` so that we can change a partition that's in use:

```console
# sfdisk -N 2 /dev/mmcblk0 --force
```

sfdisk will greet you with a scary warning. Fear not; we don't have much to do. Next input the following in the sfdisk shell:

```console
/dev/mmcblk0p2: - +
```

Is that it? What does it mean? Well, the `-` tells sfdisk to leave the beginning of the partition where it is and the `+` tells it to fill the remaining space. After the command is received, sfdisk will show you the new partition table and ask if you want to write this to disk. Press `y` to confirm.

Reboot your system:

```console
# reboot now
```

Log back in and resize the file system:

```console
# resize2fs /dev/mmcblk0p2
```

Restart, log in and confirm the changes are reflected in the partition table:

```console
# df -h
```

You should see `/dev/root` is now almost the full size of the SD card.

### Step 5. Get on Wi-Fi

Three points to note up front:

- The next couple of steps draw heavily on Kevin Patel's [excellent guide][kp-guide]. Thank you Kevin for writing this. I don't think I would have got my setup working without it!

[kp-guide]: https://blog.kevindirect.com/post/20191109_nine-steps-to-void-linux-on-rpi/ "Read 'Nine Steps to Void Linux on Raspberry Pi'"

- The default shell for the root user is Dash. It does not have the same niceties as Bash (particularly tab completion) and so while I've omitted the invocations to focus on the key aspects, I strongly recommend running `bash` after every reboot.

- If you're not using Wi-Fi, feel free to skip this step.

We need to find out the name of our wireless device. It's probably something like `wlan0` but for the rest of this post, I'll refer to it as `<device>`.

Find the name:

```console
# ip link
```

Change to the following directory:

```console
# cd /etc/wpa_supplicant
```

Make a copy of the default configuration:

```console
# cp wpa_supplicant.conf wpa_supplicant-<device>.conf
```

Add the network details:

```console
# wpa_passphrase <ssid> <key> >> wpa_supplicant-<device>.conf
```

Start the daemon:

```console
# wpa_supplicant -B -i<device> -cwpa_supplicant-<device>.conf
```

Enable the dhcpd service:[^runit]

```console
# ln -s /etc/sv/dhcpcd /var/service/
```

Test the connection:

```console
# ping voidlinux.org
```

Hopefully you're seeing sweet responses. Enable the wpa_supplicant service:

```console
# ln -s /etc/sv/wpa_supplicant /var/service/
```

### Step 6. Set up the system time

Unlike most computers, the Raspberry Pi does not have a battery-powered clock that it uses to 'remember' the current time when you shut it down. This can cause issues when updating packages so now that we have access to the Internet, let's enable the system time daemon:

```console
# ln -s /etc/sv/ntpd /var/service/
```

Reconfigure chrony:

```console
# xbps-reconfigure -f chrony
```

Reboot again, log in and check if it works (you might need to wait a little for chrony to contact the server and update):

```console
# date
```

### Step 7. Sync and update

Sync and update:

```console
# xbps-install -Su
```

Run this again to make sure everything is up to date:

```console
# xbps-install -Su
```

### Step 8. Set up D-Bus

Enable the dbus daemon:

```console
# ln -s /etc/sv/dbus /var/service/
```

Reboot:

```console
# reboot now
```

### Step 9. Set up SSH

Enable the sshd daemon:

```console
# ln -s /etc/sv/sshd /var/service/
```

Find your IP address:

```console
# ip addr
```

Try to SSH from another machine:

```console
# ssh root@<ip-address>
```

### Step 10. Create an ordinary user

Create a user and add it to some basic groups:[^bsd]

```console
# useradd -m -s /bin/bash -g users -G wheel,network,audio,video <username>
```

Change the password:

```console
# passwd <username>
```

To give users in the wheel group the power to `sudo`, first start `visudo`:

```console
# visudo
```

Then uncomment the following:

```conf
# %wheel ALL=(ALL) ALL
```

At this point, you should be able to SSH into the Pi as your new user.

## Wrap-Up

At this point, you probably want to tweak your SSH configuration (`/etc/ssh/sshd_config`) but I'll leave that, and any other software you want to install up to you. Welcome to the Void!

[^size]: If you create your own image from the rootfs tarballs, you can choose a different size. I found this process intimidating and went with the simpler approach of resizing the root partition.

[^runit]: One of the differences between Void Linux and most other Linux distributions is that it does not use systemd. The runit system that Void uses instead loads the entries that are in `/var/service`. The common practice is to symlink services you want to 'enable' into this directory.

[^bsd]: Perhaps betraying its BSD heritage, Void Linux calls its admin group 'wheel' by default.
