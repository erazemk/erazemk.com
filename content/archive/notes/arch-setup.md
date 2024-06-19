+++
title = "Arch Linux Laptop Setup (post-install)"
draft = true
+++

These notes outline my Arch post-installation with Sway.

Software list: [arch-packages.txt](/arch-packages.txt)

AUR software list: [arch-aur-packages.txt](/arch-aur-packages.txt)

**TODO:**
* [Plymouth](https://wiki.archlinux.org/index.php/Plymouth) config
* Lock screen config
* Login manager (ly)

### Screen locking

Add a service to lock the screen before suspending: `nvim /etc/systemd/system/screenlock.service`:
```
[Unit]
Description = Lock the screen
Before = sleep.target

[Service]
User = <username>
Environment = DISPLAY=:0
ExecStart = <screen-lock-command>

[Install]
WantedBy=sleep.target
```

## Software configuration

Most of the installed software either doesn't require manual configuration or has been
configured in the dotfiles repo.

Configuration for the rest is described below:

### Bumblebee

```sh
gpasswd -a <user> bumblebee
systemctl enable bumblebeed
```

(system changes - restart system afterwards)

### CUPS

```sh
systemctl enable --now cups.socket
systemctl enable --now avahi-daemon.service
```

### Deluge

```sh
systemctl enable --now --user deluged.service
systemctl enable --now --user deluge-web.service
```

### Syncthing

```sh
systemctl enable --now --user syncthing.service
```

### QEMU

Create a BTRFS subvolume for QEMU images (disable COW):
```
mkdir -p ~/.local/share/qemu
chattr +C ~/.local/share/qemu
```
