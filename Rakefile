require File.expand_path("#{File.dirname(__FILE__)}/lib/task/dev.rb")

ENV['HOME'] = PROJ_DIR # hack to keep .cabal under this project dir.

Dir.glob("#{PROJ_HOME}/lib/task/*.rake"){|p| import p}

desc "start src development".green
task :cc => :start_src_dev

desc "compile/link code".green
task :c => 'dev:all'

desc "test code".green
task :t => :test

task :start_src_dev => ['dev:start']
task :stop => ['db:stop','es:stop']
task :spec => 'dev:spec'
task :test => 'dev:test'
task :clean => 'dev:clean'
task :build => 'dev:build'
task :install => 'dev:install'
task :update => 'dev:update'
task :clean => 'dev:clean'
task :ghci => 'dev:ghci'

task :main, [:opts] => 'run:main'
task :spec, [:opts] => 'run:spec'
task :ab, [:clients,:requests,:url,:opts] => 'run:ab'

task :default do; sh "rake -T", verbose: false; end

# semantically similiar to its ./lib/redir/Dockerfile
desc "make a docker container for redir"
task :redir => [:clean,:c] do |t|
  name = task2name t.name
  path = mk_docker_dir(name)
  sh "cp #{SRC_DIR}/Main #{path}/redir"
  sh "cp #{ETC_DIR}/redir.yml #{path}/redir.yml"
  sh "cp #{LIB_DIR}/docker/redir/Dockerfile #{path}/"
  task('docker:mk').invoke(path,name)
end

# semantically similiar to its ./lib/redir/Dockerfile
desc "make a docker container for mighttpd"
task :mighttpd do |t|
  task('docker').invoke(task2name(t.name))
end

# semantically similiar to its ./lib/redir/Dockerfile
desc "make a docker container for marathon"
task :marathon do |t|
  task('docker').invoke(task2name(t.name))
end

desc "make a docker container for dhcpd"
task :dhcpd do |t|
  task('docker').invoke(task2name(t.name))
end

desc "make a docker container for zookeeper"
task :zookeeper do |t|
  task('docker').invoke(task2name(t.name))
end

desc "make a docker container for mesos"
task :mesos do |t|
  task('docker').invoke(task2name(t.name))
end

desc "make a docker container for mesos"
task :mesosslave do |t|
  task('docker').invoke(task2name(t.name))
end

desc "make a docker container for chronos"
task :chronos do |t|
  task('docker').invoke(task2name(t.name))
end

desc "make a docker container for ddt"
task :ddt do |t|
  task('docker').invoke(task2name(t.name))
end

desc "make a docker image"
task :docker, :name do |t,arg|
  raise "mising docker-image name" if arg.name.nil?
  path = mk_docker_dir(arg.name)
  task('docker:mk').invoke(path,arg.name)
end

namespace :s do
  desc "start redir"
  task :default, [:name,:opts,:debug] do |t,arg|
    start(arg.name,'--publish-all' + " #{arg.opts}",!arg.debug.nil?)
  end

  desc "start redir"
  task :redir, [:opts,:debug] do |t,arg|
    start('redir','--publish-all' + " #{arg.opts}",!arg.debug.nil?)
  end

  desc "start mighttpd (mighty)"
  task :mighttpd, [:opts,:debug] do |t,arg|
    start('mighttpd','--publish 80:8080' + " #{arg.opts}",!arg.debug.nil?)
  end

  desc "start marathon"
  task :marathon, [:opts,:debug] do |t,arg|
    start('marathon','--publish 8000:8080' + " #{arg.opts}",!arg.debug.nil?)
  end

  desc "start dhcpd"
  task :dhcpd, [:opts,:debug] do |t,arg|
    start('dhcpd',arg.opts,!arg.debug.nil?)
  end

  desc "start zookeeper"
  task :zookeeper, [:opts,:debug] do |t,arg|
    arg.with_defaults(opts: '')
    start(task2name(t.name),"--publish 2181:2181 --publish 2888:2888 --publish 3888:3888 #{arg.opts}",!arg.debug.nil?)
  end

  desc "start a mesos master"
  task :mesos, [:opts,:debug] do |t,arg|
    arg.with_defaults(opts: '')
    start(task2name(t.name),'--net=host ' + arg.opts,!arg.debug.nil?)
  end

  desc "start a mesos slave"
  task :mesosslave, [:opts,:debug] do |t,arg|
    arg.with_defaults(opts: '')
    start(task2name(t.name),'--net=host ' + arg.opts,!arg.debug.nil?)
  end

  desc "start a mesos slave"
  task :chronos, [:opts,:debug] do |t,arg|
    arg.with_defaults(opts: '')
    start(task2name(t.name),'--publish-all ' + arg.opts,!arg.debug.nil?)
  end

  desc "start a mesos slave"
  task :ddt, [:opts,:debug] do |t,arg|
    arg.with_defaults(opts: '')
    #pipework(task2name(t.name),'--publish-all ' + arg.opts,!arg.debug.nil?)
    name = task2name(t.name)
    opts = '--publish-all' + arg.opts
    debug = !arg.debug.nil?
    unless debug
      # hack
      sh "sudo pipework br0 $(docker run --volume=/dev/log:/dev/log --detach --tty --user=root --cidfile='/tmp/ddt.pid' #{opts} #{name}) 192.168.17.10/24@192.168.17.1"
      puts "e.g.: sudo pipework br0 $DOCKER_CONTAINR_ID 192.168.17.10/24"
      puts "e.g.: sudo ip addr add 192.168.17/24 dev br0"
    else
      docker_id = arg.debug # hack
      #sh "sudo pipework br0 $(docker run --net=none --volume /dev/log:/dev/log --tty --user=root --cidfile='/tmp/ddt.pid' #{opts} #{name}) 192.168.17.10/24@192.168.17.1"
      #sh "docker run --net=none --volume /dev/log:/dev/log --interactive --tty --user=root --entrypoint=/bin/bash #{opts} #{name}"
      sh "sudo pipework br0 #{docker_id} 192.168.17.10/24@192.168.17.1"
    end
  end

  task :pipework do
    docker_id = `cat /tmp/ddt.pid`.strip
    puts docker_id.red
    sh "sudo pipework br0 #{docker_id} 192.168.17.10/24@192.168.17.1"
    #sh "rake s:ddt[,#{docker_id}]"
  end

  # @todo: refactor a lot of grossneess below
  task "run ddt workflow: start debeug_ddt and then pipework"
  task :debug_ddt, [:opts] do |t,arg|
    arg.with_defaults(opts:'')
    name = 'ddt'
    opts = arg.opts'--publish-all' + arg.opts
    debug = !arg.debug.nil?
    sh "rm -f /tmp/ddt.pid"
    sh "docker run --net=none --volume=/dev/log:/dev/log --tty --user=root --cidfile='/tmp/ddt.pid' --entrypoint=/bin/bash #{opts} #{name}"
  end

  def start(name, opts ='', debug =false)
    opts = '' if opts.nil?
    raise "missing docker-image name" if name.nil?
    unless debug
      sh "docker run --net=none --volume /dev/log:/dev/log --detach --tty #{opts} #{name}"
    else
      sh "docker run --net=none --volume /dev/log:/dev/log --interactive --tty --user=root --entrypoint=/bin/bash #{opts} #{name}"
    end
  end

  def mk_docker_dir(name)
    path = "/var/tmp/#{name}"
    sh "sudo rm -rf #{path}"
    sh "mkdir -p #{path}"
    sh "cp #{LIB_DIR}/docker/#{name}/* #{path}"
    path
  end

  # @todo: change below to be less error prone
  def task2name(name)
    name.split(':').last.strip
  end
end
