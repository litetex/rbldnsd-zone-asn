#!/bin/bash

until [ -f /zonefiles/asn.zone ]
do
    echo "Failed to find zone file! Waiting a moment"
    sleep 15
done

rbldnsd -n -r /zonefiles -b ::0/5353 v4.asnresolver.internal:ip4trie:asn.zone v6.asnresolver.internal:ip6trie:asn6.zone
