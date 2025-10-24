#!/bin/bash

rbldnsd -n -r /zonefiles -b ::0/5353 v4.asnresolver.internal:ip4trie:asn.zone v6.asnresolver.internal:ip6trie:asn6.zone
