FROM debian:12-slim

RUN apt-get update \
    && apt-get install -y bash rbldnsd \
    && rm -rf /var/lib/apt/lists/*

# Copy scripts
RUN mkdir /scripts
WORKDIR /scripts

ADD scripts/ /scripts/
# Make all sh files executable
RUN find . -type f -name '*.sh' | xargs chmod +x

ENTRYPOINT [ "/bin/bash", "-c", "/scripts/init.sh" ]
