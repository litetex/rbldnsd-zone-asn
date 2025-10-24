FROM perl:5-slim

RUN cpan install URI

RUN apt-get update \
    && apt-get install bgpdump wget dos2unix pigz zstd \
    && rm -rf /var/lib/apt/lists/*
