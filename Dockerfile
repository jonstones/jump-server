FROM ubuntu:latest

RUN apt-get update && apt-get install -y \
#    && apt-get install -y --no-install-recommends \
                && apt-get -y upgrade \
    && rm -rf /var/lib/apt/lists/*

