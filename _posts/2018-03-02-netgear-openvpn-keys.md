---
title: "Replacing OpenVPN Keys on a Netgear R7000"
layout: post
date: 2018-03-02 23:42:38 +0900
category:
tags: []
---

OpenVPN's iOS app recently started displaying the following warning for OpenVPN certificates signed with the MD5 algorithm:

> WARN TLS: received certificate signed with MD5.
> Please inform your admin to upgrade to a
> stronger algorithm. Support for MD5 will be
> dropped at end of Apr 2018

If you're seeing it when connecting to a VPN running on your Netgear router, you need to change the OpenVPN keys to fix the problem.[^1] Netgear community forum user [Diggie3][dpp] put together a [guide explaining just how to do that][drg]. The guide was written for users on Windows; I've used that as a base and modified it for users running Debian-like systems. (I was using Raspbian but it should work regardless of the variant.)

[dpp]: https://community.netgear.com/t5/user/viewprofilepage/user-id/187168

[drg]: https://community.netgear.com/t5/Nighthawk-WiFi-Routers/Netgear-R7000-and-OpenVPN-for-Android-App/m-p/1515771#M84921

**WARNING: This guide involves making changes to the files on your router. This risks damage which may be irreparable. The information is provided as-is and without warranty.**

The basic idea is that we'll generate new keys using the SHA-256 algorithm and then transfer those new keys to the router by a combination of telnet and FTP.

## Step 1. Software Installation

Ensure the necessary software is installed.

```sh
sudo apt-get update
sudo apt-get install openvpn easy-rsa telnet
```

We'll also need to ensure two Python packages are installed.

```sh
pip install pycrypto pyftpdlib
```

Now copy the Easy-RSA files and change the permissions on the directory. Replace `<username>` with your username.

```sh
sudo cp -r /usr/share/easy-rsa /etc/openvpn
sudo chown -R <username>:<username> /etc/openvpn/easy-rsa
cd /etc/openvpn/easy-rsa
```

## Step 2. Key Generation Setup

Next, we need to set up the necessary variables.

Open the file `vars` in your editor of choice and update the following variables. Values that begin with `Example` can be changed to whatever you prefer.

```
export KEY_COUNTRY="ExampleCountry"
export KEY_PROVINCE="ExampleProvince"
export KEY_CITY="ExampleCity"
export KEY_ORG="ExampleOrg"
export KEY_EMAIL="ExampleEmail"
export KEY_OU="ExampleOU"

export KEY_NAME="server"

export KEY_CN="ExampleCN"
```

Complete the final setup:

```sh
ln -s openssl-1.0.0.cnf openssl.cnf
. ./vars
./clean-all
./build-ca
```

You'll be asked to confirm the settings for the certificate authority. Since you've already set defaults for all of these in `vars`, you can just hit enter to progress through.

## Step 3. Key Generation

The next step is to create the keys for the server.

```sh
./build-key-server server
```

Again, you can confirm the settings you've already defined in `vars` by hitting enter. This time, though, there will be two additional prompts:

```
Please enter the following 'extra' attributes
to be sent with your certificate request
A challenge password []:
An optional company name []:
```

Leave both blank and hit enter. Next you'll be asked:

```
Sign the certificate? [y/n]
1 out of 1 certificate requests certified, commit? [y/n]
```

Answer `y` to both.

Now we need to create the client key.

```sh
./build-key client1
```

Again, confirm the settings you've already defined and, as with the server, don't set a challenge password and don't set an optional company name. Sign the certificate and commit the change.

Finally, we generate the Diffie-Hellman parameter.

```sh
./build-dh
```

Depending on the strength of your computer's processor, this could take some time.

Now let's package all these files up into a tar file for easier transport. We'll put the file in our home directory.

```sh
cd keys
tar cvf ~/keys.tar *.crt *.csr *.key *.pem
```


## Step 4. File Transfer Setup

First, let's switch over to our home directory.

```sh
cd
```

Now we're ready to get the router ready. The R7000 can run a telnet server for debugging purposes. Netgear has made this difficult to enable but it can still be done by sending a 'magic' packet to the router.[^2] We'll do that using a [Python script][ghs].

[ghs]: https://github.com/insanid/netgear-telenetenable

```sh
wget https://raw.githubusercontent.com/insanid/netgear-telenetenable/master/telnetenable.py
```

To run the Python script we need to know (1) the IP address of our router, (2) the MAC address of our router and (3) the administrator password.

You can find the MAC address for your router by running

```sh
arp -a
```

Depending on the number of devices, you should see something like this:

```
? (<Router IP>) at <MAC Address> [ether] on eth0
```

Now let's run the script. When entering the MAC address, enter it _without_ colon separators. So if your MAC address is `ff:ff:ff:ff:ff:ff`, you would enter this as `ffffffffffff`.

```sh
python ./telnetenable.py <Router IP> <Router MAC> admin <Router password>
```

If successful, the script will output `Sent telnet enabled payload to <Router IP>`.

To transfer the files, we're going to run an FTP server using the Python module we installed earlier. Make sure you're in the directory where the `keys.tar` file is and then run the following.

```sh
python -m pyftpdlib -w
```

Time to transfer our new keys.

## Step 5. File Transfer

Now open a new shell so we can telnet in to the router. In your new shell, type the following.

```sh
telnet <Router IP>
```

If this worked, you should see something like this:

```
BusyBox v1.7.2 (2018-01-22 22:59:25 CST) built-in shell (ash)
Enter 'help' for a list of built-in commands.

#
```

You're in, as they say in the classics. Now it's time to back up the original keys for safekeeping.

```sh
cd /tmp/openvpn/
mkdir originals
cp *.* originals
tar cvf originals.tar originals/*.*
```
{: .sh-root}

Next start the FTP program.

```sh
ftp
```

Now let's transfer our files. By default, the Python FTP server will be running on port 2121.

```ftp
open <Your IP> 2121
```

When asked for your username, enter 'anonymous'. When asked for a password, leave this blank and hit enter. Once you've logged in, you can run the following commands to copy the tar file containing the original keys _to_ your device and copy the tar file containing the new keys _from_ your device.

```ftp
put originals.tar
get keys.tar
quit
```

Almost there. Let's get our new keys out of the tar file.

```sh
tar xvf keys.tar
mv dh2048.pem dh1024.pem
```
{: .sh-root}

Renaming our DH parameter in that last line means it should all 'just work'. Our R7000 will see these files as if they're the originals and be none the wiser.

## Step 6. Reboot

Reboot the router by accessing it from the web interface and rebooting. After the router is back up, you'll need to download the OpenVPN client files to all your devices again since the client files you're currently using are for the old keys. (You can shut down the FTP server now, too.)

If it all worked, you'll be able to connect without getting any warning messages. Problem solved! A copy of the original keys should be in the `originals/` directory and a copy of the tar file is in your home directory should you need it.

Thanks again to Diggie3!

[^1]: Really Netgear is the one that should be fixing this. That said, I wouldn't hold my breath. They were made aware of this problem back in June of 2017 when the Android OpenVPN client started displaying the warning. At the time of writing it's March of 2018 and the best response they can give is that they're 'aware' of the issue.

[^2]: The telnet server will be disabled when the router reboots.
