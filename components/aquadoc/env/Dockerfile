FROM ubuntu:20:10

RUN apt-get update && \
    apt-get install -y apt-utils && \
    apt-get install -y ruby-full && \
    apt-get install -y curl && \
    apt-get install -y nano && \
    apt-get install -y git

RUN gem install octokit
RUN gem install specific_install
RUN gem specific_install https://github.com/klavinslab/aquadoc

WORKDIR /home
