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

namespace :start do
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
    start(task2name(t.name),'--publish-all ' + arg.opts,!arg.debug.nil?)
  end

  def start(name, opts ='', debug =false)
    opts = '' if opts.nil?
    raise "missing docker-image name" if name.nil?
    unless debug
      sh "docker run --detach --tty #{opts} #{name}"
    else
      sh "docker run --interactive --tty --user=root --entrypoint=/bin/bash #{opts} #{name}"
    end
  end
end

namespace :d do
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
    task('d:docker').invoke(task2name(t.name))
  end

  # semantically similiar to its ./lib/redir/Dockerfile
  desc "make a docker container for redir"
  task :marathon do |t|
    task('d:docker').invoke(task2name(t.name))
  end

  desc "make a docker container for dhcpd"
  task :dhcpd do |t|
    task('d:docker').invoke(task2name(t.name))
  end

  desc "make a docker container for zookeeper"
  task :zookeeper do |t|
    task('d:docker').invoke(task2name(t.name))
  end

  desc "make a docker container for mesos"
  task :mesos do |t|
    task('d:docker').invoke(task2name(t.name))
  end

  desc "make a docker container for mesos"
  task :mesosslave do |t|
    task('d:docker').invoke(task2name(t.name))
  end

  desc "make a docker container for chronos"
  task :chronos do |t|
    task('d:docker').invoke(task2name(t.name))
  end

  desc "make a docker container for ddt"
  task :ddt do |t|
    task('d:docker').invoke(task2name(t.name))
  end

  desc "make a docker image"
  task :docker, :name do |t,arg|
    raise "mising docker-image name" if arg.name.nil?
    path = mk_docker_dir(arg.name)
    task('docker:mk').invoke(path,arg.name)
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
