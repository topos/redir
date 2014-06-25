# redir
FROM ubuntu:14.04
MAINTAINER topos (slacket@gmail.com)

RUN echo "deb http://archive.ubuntu.com/ubuntu precise main universe" > /etc/apt/sources.list
RUN apt-get update -y 
RUN apt-get upgrade -y
RUN apt-get install -y libgmp10
RUN mkdir -p /sbin

WORKDIR /var/tmp/redir
COPY redir.yml /etc/redir.yml
COPY redir /sbin/redir

ENTRYPOINT ["/sbin/redir"]

USER daemon
EXPOSE 8080
