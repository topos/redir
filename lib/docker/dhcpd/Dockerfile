# dhcpd
FROM ubuntu:14.04
MAINTAINER topos (slacket@gmail.com)

RUN echo "deb http://archive.ubuntu.com/ubuntu trusty main universe" \
    >> /etc/apt/sources.list
RUN apt-get update -y 
RUN apt-get upgrade -y

RUN sudo apt-get install isc-dhcp-server
ADD dhcpd.conf /etc/dhcp/
ADD pipework /usr/bin/pipework

ENTRYPOINT ["pipework --wait -i eth1 && dhcpd -f eth1"]
USER daemon

