# mighttpd
FROM ubuntu:14.04
MAINTAINER topos (slacket@gmail.com)

RUN echo "deb http://archive.ubuntu.com/ubuntu precise main universe" >> /etc/apt/sources.list
RUN apt-get update -y 
RUN apt-get upgrade -y
RUN apt-get build-dep -y build-essential
RUN apt-get install -y ghc
RUN apt-get install -y haskell-platform
RUN apt-get install -y libghc-warp-dev
RUN apt-get install -y mighttpd2

ENTRYPOINT ["/usr/bin/mighty"]

USER daemon
EXPOSE 80
