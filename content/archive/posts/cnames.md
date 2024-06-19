+++
title = "Using CNAME Records for Subdomains"
date = 2020-04-20
draft = true
+++

I manage a few subdomains, which serve different purposes, but all point to the same virtual server.

When I used to use Gitlab pages for hosting my website and my knowledge about DNS was effectively non-existent,
I used a CNAME record to point my website to my Gitlab pages site.
This didn't work, but thankfully a nice person in the forums explained that I can't use a CNAME record
for the root domain name, only for subdomains.

Since then, I've only used A and AAAA (IPv4 and IPv6) records for my subdomains, which meant that I had a
bunch of subdomains pointing to the same IP address.
This wasn't ideal, since I had to update every entry when moving to a new virtual server.

Today I wondered about using a CNAME record for my subdomains, since I used such a record to redirect one of my
subdomains to a different one, and everything worked fine.

I found [this ServerFault answer](https://serverfault.com/a/181981), which told me everything I need to know.

By using a CNAME record for subdomains, although taking a small performance penalty (two DNS lookups instead of one),
you gain the ability to change just one record (the one pointing to the main domain name).
You can now immediately redirect all the subdomains to a new location.
For my requirements, this was a perfect solution.
Now I only use A and AAAA records for my main domain and my VPS server hostnames,
while all the other subdomains use CNAME records.

Thanks, Jesper!
