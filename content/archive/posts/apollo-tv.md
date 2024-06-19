+++
title = "Setting up ApolloTV's Claws on a RPi"
date = 2019-04-29
draft = true
+++

> DISCLAIMER: ApolloTV has been recently shut down, so this guide is not relevant anymore.

[ApolloTV](https://apollotv.xyz/), for those of you that do not know, is a video streaming app.
It scrapes the internet for movies and TV shows and then presents them with a nice interface in its own video player
(although you have an option to choose which video player you want).

Its stable release recently came out (a day ago at the time of writing this blog post) and I must say I love it.
One of the features I really like is the ability to set up your own server.

The setup was really easy and only took about 5 minutes, but I must admit, the instructions are a little unclear.

You can find the Github Wiki tutorial [here](https://github.com/ApolloTVofficial/Claws/wiki).

In this tutorial I want to show you how you can easily run your own server for yourself and your friends.
Let's begin...

## Initial Raspberry Pi setup

I'm only going to describe this briefly, because there have been many great tutorials on this topic.

### Download Raspbian Stretch Lite

Go to the [RaspberryPi website](https://www.raspberrypi.org/downloads/raspbian/) and download the Raspbian
Stretch Lite image (ZIP or torrent, it doesn't matter).

### Extract the image file

Extract the ZIP archive to get a ".img" file.

### Prepare an SDCard (8 GB+)

You can actually use a 4 GB or maybe even 2 GB, but those have terrible transfer speeds.
Go for 8 GB or more, or atleast get a Class 10 SDCard.

You will need to format this SDCard, the format doesn't matter as it will be overwritten.

### Flash the image to the SDCard

On Windows you can use [Win32DiskImager](https://sourceforge.net/projects/win32diskimager/files/latest/download).
Download the tool and install it. Select the image and the SDCard and press Write.

**Make sure you select the right SDCard, since all the data on it will be deleted.**

On Linux you can use dd (disk dump) command:
`sudo dd if=2019-04-08-raspbian-stretch-lite.img of=/dev/mmcblk0 bs=4M status=progress && sync`

**Do NOT just copy this command, seriously.**
dd is a very powerful command and can really screw up any drive if you're not careful.
Manually type all the parts into your terminal.

But for clarification, this is what everything means:

* if - the "input file", in this case the Raspbian image
* of - the "output file" (in Linux everything is a file), the location of your SDCard
  (usually */dev/mmcblk0* if you have a card reader) - make sure to use the device not a partition (*/dev/mmcblk0p1*)
* bs - "block size"
* && sync - execute the dd command **and** (&&) sync the devices (check if all the data has actually been transfered)

### Add an "ssh" file in the boot partition

Find the boot partition with your file manager and add an empty file called "ssh" (with no extension).
On Windows make sure you didn't just create a .txt file
(try disabling "Hide extensions for known file types" in settings).

### Boot the Pi

Place the SDCard into your Raspberry Pi and boot it.

### Connect to the Pi and change the info

Find the Pi's IP using your router and SSH into it.
It's best to set a static IP for the RPi in the router's interface.
Log in to the Pi over SSH, the default username is **pi** and the password is **raspberry**.
Now mess with the settings, run *raspi-config*, add a new user, do whatever.


## Setting up the server

### Install git and nodejs

Install git using `sudo apt install git` as the pi/whatever user.
Change directory into the */tmp* directory using `cd /tmp`.
Download nodejs from their website into the */tmp* dir using
`wget https://nodejs.org/dist/v12.0.0/node-v12.0.0-linux-armv7l.tar.xz`.
Depending on when you read this article, nodejs might already be updated.
So check [their website](https://nodejs.org/en/download/current/) and paste the
"Linux Binaries (ARM) - ARMv7" link after *wget*.
Still in the */tmp* directory type `tar -xvf node-v12.0.0-linux-armv7l.tar.xz` to extract the archive
(replace the filename with your appropriate nodejs archive).
Copy the contents of the nodejs's extracted folder into */usr/local* with
`sudo cp -r node-v12.0.0-linux-armv7l/* /usr/local/`.
All the files should now be in your $PATH, so you should be able to type *npm* and get a response.

### Clone the Claws repo

Change directory into */opt* or wherever you want to install the server to with `cd /opt`.
Now clone the Claws repo with `sudo git clone https://github.com/ApolloTVofficial/Claws.git ./claws`.
You don't really need the *./claws* part at the end, but this basically specifies where you want the repo cloned to,
in this case the "./" means *current folder (/opt)*.
Now set the folder's permissions so you can start the program as a normal user with `sudo chown pi:pi /opt/claws`.
Finally change directory into */opt/claws* with `cd claws` or `cd /opt/claws`.

### Configure the server

In the claws folder install npm dependencies with `npm install`.
Wait for the installation to finish and then copy the example config file using `cp .env.dist .env`.
Open the config file in your text editor, in this tutorial that will be *nano* with `nano .env`.

Find the line that says "SECRET_CLIENT_ID=".
This will be the same password as the one you set in your app.
It has to be exactly 32 characters long, so input some random letters and numbers or make up a password and
input it between the "".
If you only want to use this server personally (on a local network or something), you can also find the
"ENABLE_QUEUE=true" line and change *true* to *false*.
Finally save the file with CTRL+O, press ENTER to confirm the file name and CTRL+X to exit.

### Run the server

This is the part you came here for.
All you have to do now is type `npm start` inside the */opt/claws* folder and the program should automatically
run in the background. You can now safely exit the SSH session and start setting up the app.

## Configuring the app

The final thing to do is to configure the server inside the app.
To do this go to Settings -> Advanced -> Change Default Server in the app.

Under the "Server url" type your Pi's url with the port 3000 like this: **http://192.168.*.*:3000/**
Replace the "*.*" with your Pi's local IP.

As an example, my IP would be *http://192.168.0.101:3000/*.

For the "Server key" type in you password you chose for "SECRET_CLIENT_ID", the one that is 32 characters long.

Finally press OK and try loading up a TV show or movie, you should soon see sources being loaded.

## Conclusion

I hope this tutorial was in-depth enough for you to understand and be able to follow it.
If you have any comments, contributions or questions, go to the contact page and please share them with me.
You can also check the official [ApolloTV Discord Server](https://discord.gg/euyQRWs) and ask there.
