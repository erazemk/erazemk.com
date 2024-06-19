+++
title = "YubiKey for passwordless Full Disk Encryption"
draft = true
+++

To use a YubiKey as an alternative to a password for unlocking a LUKS-encrypted
disk (in my case Fedora 37), do the following:

1. Enroll the YubiKey as a 2nd key for your partition:
   `systemd-cryptenroll --fido2-device=auto --fido2-with-user-verification=false --fido2-with-client-pin=false /dev/nvme0n1pX`
2. Append `,fido2-device=auto` to the end of `/etc/crypttab` for the LUKS
   partition (e.g. `luks-XXX-YYY UUID=XXX-YYY none discard,fido2-device=auto`)
3. Regenerate dracut: `sudo dracut --regenerate-all --force`

After a reboot, when you see the Plymouth screen, press your YubiKey to unlock
the disk.
