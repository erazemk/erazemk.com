+++
title = "Arch Linux Laptop Installation"
date = 2024-06-19
description = "Notes on installing Arch Linux on a laptop."
+++

These notes outline my Arch installation with the following features(/tags):

- UEFI
- Two disks (SSD for /, HDD for /home)
- BTRFS
- `systemd-boot`
- `systemd-homed`
- Full disk encryption (LUKS) for both disks
- Laptop-specific features (hybrid sleep, tlp, automatic locking on lid close, ...)

## Pre-installation

Set the keyboard layout: `loadkeys slovene`

Check if booted in EFI mode: `ls /sys/firmware/efi/efivars` (should be non-empty)

Connect to Wi-Fi: `iwctl`

Update the system clock: `timedatectl set-ntp true`

## Disk partitioning

Wanted layout:

```
| Mount point | Partition | Filesystem   | Size     |
|-------------|-----------|--------------|----------|
| /boot       | /dev/sda1 | FAT32 (vfat) | 512M     |
| /           | /dev/sda2 | BTRFS        | 100%FREE |
| /home       | /dev/sdb1 | BTRFS        | 100%FREE |
```

Install BTRFS utils: `pacman -S btrfs-progs`

Partition the disks with `fdisk` (make sure to use GPT partitioning)

Format the boot partition: `mkfs.vfat -F32 -n boot /dev/sda1`

Enable full disk encryption:

```sh
cryptsetup -y -v luksFormat /dev/sda2
cryptsetup luksOpen /dev/sda2 arch-root
cryptsetup -y -v luksFormat /dev/sdb1
cryptsetup luksOpen /dev/sdb1 arch-home
```

Format the root and home partitions:

```sh
mkfs.btrfs -L arch-root /dev/mapper/arch-root
mkfs.btrfs -L arch-home /dev/mapper/arch-home
```

Temporarily mount the partitions:

```sh
mount -o compress=zstd,noatime /dev/mapper/arch-root /mnt
mkdir /mnt/home /mnt/boot
mount -o compress=zstd,noatime /dev/mapper/arch-home /mnt/home
```

Configure BTRFS:

```sh
btrfs subvolume create /mnt/@
btrfs subvolume create /mnt/@home
btrfs subvolume create /mnt/@swap
```

Remount the partitions:

```sh
mount -o compress=zstd,noatime,subvol=@ /dev/mapper/arch-root /mnt
mount -o compress=zstd,noatime,subvol=@home /dev/mapper/arch-home /mnt/home
mount /dev/sda1 /mnt/boot
```

Add cache and log volumes:

```
btrfs subvolume create /mnt/var/cache
btrfs subvolume create /mnt/var/log
```

## Installation

Update mirrors: `reflector -f 20 -l 20 -n 10 -p https --sort rate --verbose --save /etc/pacman.d/mirrorlist`

Install main packages: `pacstrap /mnt base base-devel linux linux-firmware neovim btrfs-progs exfatprogs ntfs-3g man-db man-pages iwd reflector fish intel-ucode tmux git rsync tlp acpi_call udisks2 opendoas util-linux`

## Configure the system

Generate `fstab`: `genfstab /mnt >> /mnt/etc/fstab`

Chroot into the system: `arch-chroot /mnt`

Set the time zone: `ln -sf /usr/share/zoneinfo/Europe/Ljubljana /etc/localtime`

Set the time: `hwclock -w`

Uncomment wanted locales: `nvim /etc/locale.gen`

Generate chosen locales: `locale-gen`

Copy the locale config: `locale > /etc/locale.conf`

Edit the locales you want: `nvim /etc/locale.conf`

Permanently set the keyboard layout: `nvim /etc/vconsole.conf`:

```
KEYMAP=slovene
FONT=lat2-16
```

Set up the hostname: `echo "t540p" > /etc/hostname`

Set up the hosts: `nvim /etc/hosts`:

```
127.0.0.1   localhost
127.0.1.1   t540p.localdomain   t540p
::1         localhost           ip6-localhost   ip6-loopback
```

### Swapfile

Setup swap:

```sh
mkdir /swap
mount -o noatime,subvol=@swap /dev/mapper/arch-root /swap

truncate -s 0 /swap/swapfile
chattr +C /swap/swapfile
btrfs property set /swap/swapfile compression none

fallocate -l 16G /swap/swapfile
mkswap /swap/swapfile

chmod 600 /swap/swapfile

swapon /swap/swapfile
```

Add the swapfile to fstab: `nano /etc/fstab`:

```
# Add:
/dev/mapper/arch-root   /swap   btrfs   rw,noatime,space_cachesubvol=@swap  0   0
/swap/swapfile          none    swap    defaults,discard                    0   0
```

### Initramfs

Configure initramfs: `nvim /etc/mkinitcpio.conf`:

```
HOOKS=(base systemd autodetect keyboard sd-vconsole modconf block sd-encrypt filesystems resume fsck)

BINARIES=(btrfs)
```

Recreate the initramfs image: `mkinitcpio -P`

### Bootloader

Set up the bootloader: `bootctl install`

Edit the bootloader config: `nvim /boot/loader/loader.conf`:

```
default arch.conf
auto-firmware 0
console-mode max
editor no
```

Add a loader: `nvim /boot/loader/entries/arch.conf`:

```
title Arch Linux
linux /vmlinuz-linux
initrd /intel-ucode.img
initrd /initramfs-linux.img
options cryptdevice=UUID=<$disk-uuid>:arch-root root=/dev/mapper/arch-root rootflags=subvol=@ quiet rw systemd.unified_cgroup_hierarchy=1
```

_\* To get the $disk-uuid use `:read ! blkid /dev/sda2` inside neovim._

Add a systemd hook: `nvim /etc/pacman.d/hooks-100-systemd-boot.hook`:

```
[Trigger]
Type = Package
Operation = Upgrade
Target = systemd

[Action]
Description = Updating systemd-boot
When = PostTransaction
Exec = /usr/bin/bootctl update
```

### Automatic disk decryption on boot

To decrypt the second (/home) disk automatically edit the crypttab: `nvim /etc/crypttab`:

```
arch-root    UUID=<$disk-uuid>   none    luks,discard
arch-home    UUID=<$disk-uuid>   none    luks
```

### Add user

Enable the service: `systemctl enable --now systemd-homed.service`

Create the user: `homectl create <username> --storage=luks --shell=/usr/bin/fish --member-of=wheel`

### Yay

Install yay:

```sh
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si
```

### Pacman

Configure pacman: `nvim pacman.conf`:

```
# Uncomment:
Color
TotalDownload
CheckSpace
VerbosePkgLists

# Add:
ILoveCandy
```

Also uncomment multilib:

```
[multilib]
Include = /etc/pacman.d/mirrorlist
```

### TLP

```sh
systemctl enable --now tlp.service
tlp setcharge 65 81 # Extend battery lifespan
```

### IWD

Enable the services:

```
systemctl enable --now systemd-resolved.service
systemctl enable --now iwd.service
```

Add the following to the iwd config file: `nvim /etc/iwd/main.conf`:

```
[General]
EnableNetworkConfiguration=true
AddressRandomization=true

[Network]
EnableIPv6=true
NameResolvingService=systemd
```

(Adjust the router-set MAC address for the laptop)

Add an [Adguard DNS](https://adguard.com/en/adguard-dns) entry to the WiFi config file: `nvim /var/lib/iwd/<wifi-name>.psk`:

```
[IPv4]
DNS=94.140.14.14
```

### Reflector

Edit the service file: `nvim /etc/xdg/reflector/reflector.conf`

```
--fastest 20
--latest 20
--number 10
--protocol https
--sort rate
--verbose
--save /etc/pacman.d/mirrorlist
```

Enable the timer: `systemctl enable reflector.timer`

### Sudo

Edit the sudo config: `EDITOR=nvim visudo`:

```
# Add:
Defaults pwfeedback

# Uncomment:
%wheel  ALL=(ALL)   ALL
```

### Dotfiles

Clone your dotfiles repo: `git clone --separate-git-dir=~/.config/dotfiles <repo> ~`

## Final touches

Set the root password: `passwd`

Enable weekly SSD trim: `systemctl enable fstrim.timer`

Exit the chroot: `exit` (or press `Ctrl+d`)

Unmount the mounted partitions: `umount -R /mnt`

Reboot the system: `reboot`
