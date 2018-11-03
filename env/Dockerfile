FROM ubuntu:latest

RUN apt-get update && \
    apt-get install -y apt-utils && \
    apt-get install -y ruby-full && \
    apt-get install -y curl && \
    apt-get install -y nano && \
    apt-get install -y git && \
    apt-get install -y npm

RUN npm install -g bower

RUN gem install specific_install

WORKDIR /home
