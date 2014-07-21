# redir
FROM ubuntu:14.04
MAINTAINER topos (slacket@gmail.com)

RUN echo "deb http://archive.ubuntu.com/ubuntu trusty main universe" \
    >> /etc/apt/sources.list
RUN apt update -y 
RUN apt upgrade -y
RUN apt install -y libgmp10
RUN apt install -y udhcpc
RUN apt install -y traceroute
RUN apt install -y dhcping 
RUN apt install -y dhcpdump
RUN apt install -y python-pydhcplib

WORKDIR /var/tmp/redir
ADD redir.yml /etc/
ADD redir /usr/local/sbin/
RUN chmod +x /usr/local/sbin/redir

USER daemon
EXPOSE 8080
ENTRYPOINT ["/usr/local/sbin/redir"]
