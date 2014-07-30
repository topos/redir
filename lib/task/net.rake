namespace :net do
  DOCKER = 'docker0'
  DEV_NAME = 'dev0'
  desc "make a network:open-vswitch bridge =dev0"
  task :mk, [:name] do |t,arg|
    dev_name = arg.name.nil? ? DEV_NAME : arg.name
    sh "bundle exec rake net:unmk || exit 0"
    sh "sudo ovs-vsctl add-br #{dev_name}"
    sh "sudo brctl addif #{DOCKER} #{dev_name}"
    # drop DHCP request/replies on "dev_name" open-vswitch bridge
    # - this will let us run multiple DHCP serwers on the network
    #   but still communicate between containers
    sh "sudo ovs-ofctl add-flow #{dev_name} udp,tp_src=68,tp_dst=67,action=drop"
    sh "sudo ovs-ofctl add-flow #{dev_name} udp,tp_src=67,tp_dst=68,action=drop"
  end

  desc "unmake a network:open-vswitch bridge =dev0"
  task :unmk, [:name] do |t,arg|
    dev_name = arg.name.nil? ? DEV_NAME : arg.name
    sh "sudo ovs-vsctl del-br #{dev_name}"
  end

  desc "list interfaces in dev net"
  task :list, [:name] do |t,arg|
    arg.with_defaults(name:DEV_NAME)
    sh "sudo ovs-vsctl list-br"
    sh "sudo ovs-vsctl list-ports #{arg.name}"
  end
  task :ls => :list

  desc "start a docker/lxc container, assign ip | dhcp, join dev net"
  task :add, [:docker_img,:opts,:cidr_dhcp,:debug,:name] do |t,arg|
    raise "docker_img can't be nil" if arg.docker_img.nil?
    arg.with_defaults(opts:'',cidr_dhcp:'dhcp',name:DEV_NAME)
    begin
      cid = start(arg.docker_img,arg.opts,!arg.debug.nil?)
      puts cid.green
      task('net:join').invoke(cid,arg.cidr_dhcp,arg.debug,arg.name) if arg.debug.nil?
    rescue
      puts $!
    end
  end

  desc "join a container (by name or id) to your dev net"
  task :join, [:container,:cidr_dhcp,:name] do |t,arg|
    raise "container (id or name) can't be nil" if arg.container.nil?
    arg.with_defaults(cidr_dhcp:'dhcp',name:DEV_NAME)
    sh "sudo pipework #{arg.name} #{arg.container} #{arg.cidr_dhcp}"
  end

  desc "add a docker/lxc container to your dev net by name or id"
  task :del, [:container,:name] do |t,arg|
    raise "container cannot be nil" unless arg.container.nil?
    arg.with_defaults(name:DEV_NAME) 
    sh "echo sudo ovs-vsctl del-port #{arg.name} <container to interface>"
  end

  def start(name,opts='',debug=false)
    raise "missing docker-image name" if name.nil?
    require 'uuid'
    cidfile = "/var/tmp/#{UUID.new.generate}.cid"
    begin
      unless debug
        sh "docker run #{opts} --cidfile=#{cidfile} --privileged --volume=/dev/log:/dev/log --detach --tty #{name}"
      else
        sh "docker run #{opts} --cidfile=#{cidfile} --privileged --volume=/dev/log:/dev/log --interactive --tty --user=root --entrypoint=/bin/bash #{name}"
      end
      `cat #{cidfile}`.strip
    ensure
      sh "echo sudo rm -f #{cidfile}"
    end
  end
end
