+++
title = "Yubikey for LUKS"
date = 2024-06-19
description = "How to use a Yubikey as an alternative to a password for unlocking a LUKS-encrypted disk."
+++

To use a Yubikey as an alternative to a password for unlocking a LUKS-encrypted disk (in my case, Fedora 37), do the following:

1. Enroll the Yubikey as a second key for your partition: `systemd-cryptenroll --fido2-device=auto --fido2-with-user-verification=false --fido2-with-client-pin=false /dev/nvme0n1pX`
2. Append `,fido2-device=auto` to the end of `/etc/crypttab` for the LUKS partition (e.g. `luks-XXX-YYY UUID=XXX-YYY none discard,fido2-device=auto`)
3. Regenerate dracut: `sudo dracut --regenerate-all --force`

After a reboot, when you see the Plymouth screen, press your Yubikey to unlock the disk.
