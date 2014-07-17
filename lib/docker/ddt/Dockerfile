# stolen from https://github.com/jpetazzo/pxe/blob/master/Dockerfile
FROM ubuntu:14.04
MAINTAINER topos (slacket@gmail.com)

RUN apt-get -q update
RUN apt-get upgrade -y
RUN apt-get -qy install dnsmasq wget

ENV ARCH amd64
ENV DIST trusty
ENV MIRROR http://archive.ubuntu.com

WORkDIR /usr/bin
RUN wget --no-check-certificate https://raw.github.com/jpetazzo/pipework/master/pipework
RUN chmod +x pipework

RUN mkdir /tftp
WORKDIR /tftp
RUN wget $MIRROR/ubuntu/dists/$DIST/main/installer-$ARCH/current/images/netboot/ubuntu-installer/$ARCH/linux
RUN wget $MIRROR/ubuntu/dists/$DIST/main/installer-$ARCH/current/images/netboot/ubuntu-installer/$ARCH/initrd.gz
RUN wget $MIRROR/ubuntu/dists/$DIST/main/installer-$ARCH/current/images/netboot/ubuntu-installer/$ARCH/pxelinux.0

RUN mkdir pxelinux.cfg
RUN printf "DEFAULT linux\nKERNEL linux\nAPPEND initrd=initrd.gz\n" > pxelinux.cfg/default

ADD ddt-start /usr/sbin/
RUN chmod +x /usr/sbin/ddt-start
RUN mkdir -p /var/lib/misc && chown daemon /var/lib/misc

USER root
ENTRYPOINT ["/usr/sbin/ddt-start"]
