FROM ubuntu:latest

RUN apt-get update && \
    apt-get install -y --no-install-recommends apt-utils && \
    apt-get install -y ruby-full && \
    apt-get install -y curl && \
    apt-get install -y nano && \
    apt-get install -y git

RUN gem install specific_install

WORKDIR /home
