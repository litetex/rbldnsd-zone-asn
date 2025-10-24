FROM perl:5-slim

RUN apt-get update \
    && apt-get install bgpdump wget dos2unix \
    && cpan install URI
