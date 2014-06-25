# redir
FROM ubuntu
MAINTAINER ml1 (slacket@gmail.com)

RUN echo "deb http://archive.ubuntu.com/ubuntu precise main universe" > /etc/apt/sources.list
RUN apt-get update -y && apt-get upgrade -y && \
    apt-get install -y libgmp10

RUN mkdir -p /opt/redir
WORKDIR /var/tmp/redir
COPY redirect.yml /opt/redir/
COPY redird /opt/redir/

ENTRYPOINT ["/opt/redir/redird"]

USER daemon
EXPOSE 8080
