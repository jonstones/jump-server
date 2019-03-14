FROM ubuntu:latest

RUN apt-get update &&
    && apt-get install -y \
#    && apt-get install -y --no-install-recommends \
                upgrade \
    && rm -rf /var/lib/apt/lists/*

