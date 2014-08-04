namespace :net do
  DOCKER = 'docker0'
  DEVNET_NAME = 'dev0'
  DEVNET_CIDR = '192.168.16.1/24'

  desc "make a network:open-vswitch bridge =dev0"
  task :mk, [:name,:cidr] do |t,arg|
    arg.with_defaults(name:DEVNET_NAME,cidr:DEVNET_CIDR)
    devnet = arg.name.nil? ? DEVNET_NAME : arg.name
    sh "bundle exec rake net:unmk[#{arg.name}] >/dev/null 2>&1 || exit 0"
    sh "sudo ovs-vsctl add-br #{devnet}"
    sh "sudo ip addr add #{arg.cidr} dev #{devnet}"
    sh "sudo brctl addif #{DOCKER} #{devnet}"
    # drop DHCP request/replies on "devnet" open-vswitch bridge
    # - this will let us run multiple DHCP serwers on the network
    #   but still communicate between containers
    #sh "sudo ovs-ofctl add-flow #{devnet} udp,tp_src=68,tp_dst=67,action=drop"
    #sh "sudo ovs-ofctl add-flow #{devnet} udp,tp_src=67,tp_dst=68,action=drop"
  end
  task :make => :mk

  desc "unmk (unmake) a network:open-vswitch bridge =dev0"
  task :unmk, [:name] do |t,arg|
    devnet = arg.name.nil? ? DEVNET_NAME : arg.name
    sh "sudo ovs-vsctl del-br #{devnet}"
  end
  task :unmake => :unmk

  desc "remove all devices from ovs switch"
  task :clean, [:name] do |t,arg|
    arg.with_defaults(name: 'dev0')
    `sudo ovs-vsctl list-ports #{arg.name}`.split.each do |port|
      sh "sudo ovs-vsctl del-port #{port}"
    end
  end

  desc "list interfaces in dev net"
  task :ls, [:name] do |t,arg|
    arg.with_defaults(name:DEVNET_NAME)
    sh "sudo ovs-vsctl list-br"
    sh "sudo ovs-vsctl list-ports #{arg.name}"
  end
  task :list => :ls

  desc "start a docker/lxc container, assign ip | dhcp, join dev net"
  task :add, [:docker_image_name,:cidr_dhcp,:name,:opts] do |t,arg|
    raise "docker_image_name can't be nil" if arg.docker_image_name.nil?
    arg.with_defaults(cidr_dhcp:'dhcp',name:DEVNET_NAME,opts:'')
    cid = start(arg.docker_image_name,arg.opts)
    pid = `docker inspect --format "{{.State.Pid}}" #{cid}`.strip
    puts "container ID: #{cid}".green
    task('net:join').invoke(cid,arg.cidr_dhcp,arg.name)
  end

  desc "join a container (by name or id) to your dev net"
  task :join, [:container,:cidr_dhcp,:name] do |t,arg|
    raise "container (id or name) can't be nil" if arg.container.nil?
    arg.with_defaults(cidr_dhcp:'dhcp',name:DEVNET_NAME)
    sh "sudo #{PROJ_DIR}/bin/pipework #{arg.name} #{arg.container} #{arg.cidr_dhcp}"
  end

  desc "rm (remove) a docker/lxc container to your dev net by name or id"
  task :rm, [:container,:name] do |t,arg|
    raise "container cannot be nil" unless arg.container.nil?
    arg.with_defaults(name:DEVNET_NAME) 
    sh "echo sudo ovs-vsctl del-port #{arg.name} <container to interface>"
  end

  def start(name,opts='',debug =false)
    raise "missing docker-image name" if name.nil?
    require 'uuid'
    cidfile = "/var/tmp/#{UUID.new.generate}.cid"
    begin
      cmd = [] 
      cmd += %w(docker run)
      cmd << "--cidfile=#{cidfile}"
      cmd += %w(--privileged --volume=/dev/log:/dev/log --tty) 
      unless debug
        cmd += %w(--detach)
      else
        cmd += %w(--interactive  --user=root --entrypoint=/bin/bash)
      end
      cmd += opts.split
      cmd << name
      sh cmd.join ' '
      `cat #{cidfile}`.strip
    ensure
      sh "echo sudo rm -f #{cidfile}"
    end
  end
end
