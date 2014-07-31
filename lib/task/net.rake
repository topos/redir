namespace :net do
  DOCKER = 'docker0'
  DEVNET_NAME = 'dev0'
  DEVNET_CIDR = '192.168.16.1/24'

  desc "make a network:open-vswitch bridge =dev0"
  task :mk, [:name] do |t,arg|
    devnet = arg.name.nil? ? DEVNET_NAME : arg.name
    sh "bundle exec rake net:unmk >/dev/null 2>&1 || exit 0"
    sh "sudo ovs-vsctl add-br #{devnet}"
    sh "sudo ip addr add #{DEVNET_CIDR} dev #{devnet}"
    sh "sudo brctl addif #{DOCKER} #{devnet}"
    # drop DHCP request/replies on "devnet" open-vswitch bridge
    # - this will let us run multiple DHCP serwers on the network
    #   but still communicate between containers
    #sh "sudo ovs-ofctl add-flow #{devnet} udp,tp_src=68,tp_dst=67,action=drop"
    #sh "sudo ovs-ofctl add-flow #{devnet} udp,tp_src=67,tp_dst=68,action=drop"
  end

  desc "rm a network:open-vswitch bridge =dev0"
  task :unmk, [:name] do |t,arg|
    devnet = arg.name.nil? ? DEVNET_NAME : arg.name
    sh "sudo ovs-vsctl del-br #{devnet}"
  end

  desc "list interfaces in dev net"
  task :list, [:name] do |t,arg|
    arg.with_defaults(name:DEVNET_NAME)
    sh "sudo ovs-vsctl list-br"
    sh "sudo ovs-vsctl list-ports #{arg.name}"
  end
  task :ls => :list

  desc "start a docker/lxc container, assign ip | dhcp, join dev net"
  task :add, [:docker_img,:cidr_dhcp,:opts,:debug,:name] do |t,arg|
    raise "docker_img can't be nil" if arg.docker_img.nil?
    arg.with_defaults(cidr_dhcp:'dhcp',opts:'',name:DEVNET_NAME)
    begin
      cid = start(arg.docker_img,arg.opts,!arg.debug.nil?)
      pid = `docker inspect --format "{{.State.Pid}}" #{cid}`.strip
      procn = `ps -eaf | grep #{pid}`.strip
      puts "container ID: #{cid}".green
      #puts "container PID: #{pid} (#{procn})" # @todo: needs a stronger regex match
      task('net:join').invoke(cid,arg.cidr_dhcp,arg.debug,arg.name) if arg.debug.nil?
    rescue
      puts $!
    end
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

  def start(name,opts='',debug=false)
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
