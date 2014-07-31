namespace :app do
  task :start, [:name,:debug,:opts] do |t,arg|
    raise ":name of image is nil" if arg.name.nil?
    arg.with_defaults(debug:'',opts:'')
    opts = arg.opts.split /\s/
    opts << '--privileged'
    opts << '--volume=/dev/log:/dev/log' 
    opts << '--tty'
    opts.uniq!
    sh "rake docker:start[#{arg.name},#{arg.debug},'#{(opts.uniq.join ' ').strip}']"
  end

  # @todo: refactor--get rid of boilerplate
  namespace :start do
    desc "start redir"
    task :redir, [:debug,:opts] do |t,arg|
      arg.with_defaults(opts:'',debug:'')
      sh "rake app:start[#{task2name(t.name)},#{arg.debug},'--publish-all #{arg.opts}']"
    end

    desc "start mighttpd (mighty)"
    task :mighttpd, [:debug,:opts] do |t,arg|
      arg.with_defaults(opts:'',debug:'')
      sh "rake app:start[#{task2name(t.name)},#{arg.debug},'--publish-all #{arg.opts}']"
    end

    desc "start marathon"
    task :marathon, [:debug,:opts] do |t,arg|
      arg.with_defaults(opts:'',debug:'')
      sh "rake app:start[#{task2name(t.name)},#{arg.debug},'--publish-all #{arg.opts}']"
    end

    desc "start dhcpd"
    task :dhcpd, [:debug,:opts] do |t,arg|
      arg.with_defaults(opts:'',debug:'')
      sh "rake app:start[#{task2name(t.name)},#{arg.debug},'--publish-all #{arg.opts}']"
    end

    desc "start zookeeper"
    task :zookeeper, [:debug, :opts] do |t,arg|
      arg.with_defaults(opts:'',debug:'')
      sh "rake app:start[#{task2name(t.name)},#{arg.debug},'--publish-all #{arg.opts}']"
    end

    desc "start a mesos master"
    task :mesos, [:debug,:opts] do |t,arg|
      arg.with_defaults(opts:'',debug:'')
      sh "rake app:start[#{task2name(t.name)},#{arg.debug},'--publish-all #{arg.opts}']"
    end

    desc "start a mesos slave"
    task :mesosslave, [:debug,:opts] do |t,arg|
      arg.with_defaults(opts:'',debug:'')
      sh "rake app:start[#{task2name(t.name)},#{arg.debug},'--publish-all #{arg.opts}']"
    end

    desc "start a mesos slave"
    task :chronos, [:debug,:opts] do |t,arg|
      arg.with_defaults(:debug,opts:'')
      sh "rake app:start[#{task2name(t.name)},#{arg.debug},'--publish-all #{arg.opts}']"
    end

    desc "start a mesos slave"
    task :ddt, [:debug,:opts] do |t,arg|
      arg.with_defaults(opts:'',debug:'')
      sh "rake app:start[#{task2name(t.name)},#{arg.debug},'--publish-all #{arg.opts}']"
    end

    desc "start a mesos slave"
    task :consul, [:debug,:opts] do |t,arg|
      arg.with_defaults(opts:'',debug:'')
      sh "rake app:start[#{task2name(t.name)},#{arg.debug},'--publish-all #{arg.opts}']"
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

  namespace :mk do
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

    desc "make a docker container for cosul"
    task :consul do |t|
      task('docker').invoke(task2name(t.name))
    end

    desc "make a docker image"
    task :docker, :name do |t,arg|
      raise "mising docker-image name" if arg.name.nil?
      path = mk_docker_dir(arg.name)
      task('docker:mk').invoke(path,arg.name)
    end
  end
end

