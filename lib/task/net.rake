namespace :net do
  DOCKER = 'docker0'
  DEV_NAME = 'dev0'
  desc "make a network:open-vswitch bridge =dev0"
  task :mk, [:name] do |t,arg|
    dev_name = arg.name.nil? ? DEV_NAME : arg.name
    sh "sudo ovs-vsctl del-br #{dev_name} || exit 0"
    sh "sudo ovs-vsctl add-br #{dev_name}"
    sh "sudo brctl addif #{DOCKER} #{dev_name}"
  end

  DOCKER_NET = '172.17.17.0/24'
  DOCKER_IP = '172.17.17.1'
  task :mk_old, [:name] do |t,arg|
    dev_name = arg.name.nil? ? DEV_NAME : arg.name
    # reset docker0--@todo: may not be necessary
    sh "sudo ip link set #{DOCKER} down || exit 0"
    sh "sudo brctl delbr #{DOCKER} || exit 0"
    sh "sudo ovs-vsctl del-br #{DOCKER} || exit 0"
    # @todo: may not be necessary
    sh "sudo brctl addbr #{DOCKER}"
    sh "sudo ip a add #{DOCKER_IP} dev #{DOCKER}"
    sh "sudo ip link set #{DOCKER} up"

    sh "sudo ovs-vsctl del-br #{dev_name} || exit 0"
    sh "sudo ovs-vsctl add-br #{dev_name}"
    sh "sudo brctl addif #{DOCKER} #{dev_name}"

    # enable NAT
    sh "sudo iptables -t nat -A POSTROUTING -s #{DOCKER_NET} ! -d #{DOCKER_NET} -j MASQUERADE"
    # accept incoming packets for existing connections
    sh "sudo iptables -A FORWARD -o #{DOCKER} -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT"
    # accept all non-intercontainer outgoing packets
    sh "sudo iptables -A FORWARD -i #{DOCKER} ! -o #{DOCKER} -j ACCEPT"
    # by default allow all outgoing traffic
    sh "sudo iptables -A FORWARD -i #{DOCKER} -o #{DOCKER} -j ACCEPT"
    # drop DHCP request/replies on "dev_net" open-vswitch bridge
    # - this will let us run multiple DHCP serwers on the network
    #   but still communicate between containers
    sh "sudo ovs-ofctl add-flow #{dev_name} udp,tp_src=68,tp_dst=67,action=drop"
    sh "sudo ovs-ofctl add-flow #{dev_name} udp,tp_src=67,tp_dst=68,action=drop"
  end
end
