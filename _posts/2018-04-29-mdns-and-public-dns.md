---
title: "mDNS Name Resolution and Public DNS Servers"
layout: post
date: 2018-04-29 15:49:39 +0900 
excerpt: There's a problem with mDNS name resolution when using public DNS servers on Netgear routers.
category: 
tags: []
---

On 1 April 2018, Cloudflare announced a public DNS service with the ludicrously cool IP address 1.1.1.1. I was excited to start using this given Cloudflare's stance on privacy and quickly logged into my Netgear R7000 router and switched its DNS servers over.

Unfortunately, I've had to change it back. I'm not sure precisely what's causing the problem but when I manually set the DNS servers—whether to Cloudflare's or another like Google's—mDNS name resolution[^1] breaks between my Apple devices and my Linux devices.

I don't have a solution. I switched to manually specifying the DNS servers on each device and the problem didn't recur. I hadn't seen anyone else talking about this anywhere so I wanted to write up the discovery on the blog. Hopefully someone smarter than me comes along and finds a fix.

[^1]: [Multicast domain name service](https://en.wikipedia.org/wiki/Zero-configuration_networking#Name_service_discovery) is a technology that, among other things, allows devices on the same network to find and identify each other. When enabled, it allows one device to find another device at the address `<hostname>.local` regardless of the actual IP address of the device.

