# dhcpd
FROM ubuntu:14.04
MAINTAINER topos (slacket@gmail.com)

RUN DEBIAN_FRONTEND=noninteractive apt-get update -y 
RUN DEBIAN_FRONTEND=noninteractive apt-get upgrade -y
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y unzip

WORKDIR /var/tmp
RUN mkdir -p /consul/data
ADD https://dl.bintray.com/mitchellh/consul/0.3.1_linux_amd64.zip /var/tmp/consul.zip
RUN unzip ./consul.zip -d /consul/bin/ && chmod +x /consul/bin/consul
ADD https://dl.bintray.com/mitchellh/consul/0.3.1_web_ui.zip /var/tmp/webui.zip
RUN unzip ./webui.zip -d /consul/ && mv -f /consul/dist /consul/webui
RUN rm -f *.zip

# consul service ports:
# - server rpc: 8300
# - serf lan: 8301
# - serf wan: 8302
# - client rpc: 8400
# - http api: 8500 (wui)
# - dns: 8600
EXPOSE 8300 8301 8302 8400 8500 8600/udp

WORKDIR /consul
USER daemon
ENTRYPOINT ["/consul/bin/consul","agent","-data-dir","/consul/data"]
