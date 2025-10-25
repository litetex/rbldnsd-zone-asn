# How to test

```bash

docker exec -it demo-dns-client bash

# IP's of Cloudflares public DNS resolvers
dig @fd00:5353::99 -p 5353 1.1.1.1.v4.asnresolver.internal TXT
dig @fd00:5353::99 -p 5353 1.1.1.1.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.7.4.0.0.7.4.6.0.6.2.v6.asnresolver.internal TXT

```