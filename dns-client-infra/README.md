# How to test

```bash

docker exec -it demo-dns-client bash

# IP's of Cloudflares public DNS resolvers
dig @v4.asnresolver.internal 1.1.1.1.v4.asnresolver.internal TXT
dig @v6.asnresolver.internal 1.1.1.1.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.7.4.0.0.7.4.6.0.6.2.v6.asnresolver.internal TXT

```