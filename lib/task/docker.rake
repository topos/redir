namespace :docker do
  desc 'run bash within a container'
  task :sh, [:cmd,:image] do |t,arg|
    arg.with_defaults(image:'ubuntu')
    if arg.cmd.nil?
      sh "docker run -i -t #{arg.image} /bin/bash"
    else
      sh "docker run -i -t #{arg.image} '#{arg.cmd}'"
    end
  end

  desc 'make container'
  task :mk, [:docker_dir,:name] do |t,arg|
    raise "no docker_dir arg.".red if arg.docker_dir.nil?
    raise "no name arg.".red if arg.name.nil?
    Dir.chdir arg.docker_dir do
      sh "docker build --rm --tag=#{arg.name} ."
    end
  end

  desc 'list of docker files'
  task :files do
    sh "ls #{LIB_DIR}/docker".green
  end

  desc 'info'
  task :info do
    v = `docker --version`.strip
    puts "#{v}".cyan
    d = `which docker`.strip
    puts "#{d}".green

    msg = <<EOF
memory and swap accounting
  if you want to enable memory and swap accounting, you must add the following 
  command-line parameters to your kernel:

  $ cgroup_enable=memory swapaccount=1https://github.com/sinatra/sinatra-contrib/issues/111

  Add the above parameters by editing /etc/default/grub and extending 
  GRUB_CMDLINE_LINUX. Look for the following line:

  $ GRUB_CMDLINE_LINUX=""

  And replace it with the following:
  $ GRUB_CMDLINE_LINUX="cgroup_enable=memory swapaccount=1"

  $ sudo update-grub
  $ reboot
EOF
    puts msg.strip.yellow
  end

  desc "non-root (user) access"
  task :user_access do
    sh "sudo groupadd docker || exit 0"
    sh "sudo gpasswd -a #{ENV['LOGNAME']} docker"
    puts "type rake docker:restart".red
  end

  desc 'install docker'
  task :install => 'docker:install:pkg'

  # container
  namespace :container do
    desc "list containers"
    task :list do
      sh "docker ps --all"
    end

    desc "stop all or an individual container"
    task :stop, [:cid] do |t,arg|
      if arg.cid == 'all' || arg.cid.nil?
        sh "docker stop $(docker ps --all --quiet)"
      else
        sh "docker stop #{arg.cid}"
      end
    end

    desc "stop all or a list of container IDs"
    task :start, [:ids] do |t,arg|
      raise "container ID' is required" if arg.ids.nil?
      arg.ids.split.each do |id|
        sh "docker start #{id}"
      end
    end

    desc "clean (remove) stopped containers"
    task :clean, [:cid,:opt] do |t,arg|
      arg.with_defaults(opt:'')
      begin
        if arg.cid.nil?
          sh "docker rm #{arg.opt} $(docker ps --quiet --all)"
        else
          sh "docker rm #{arg.opt} #{arg.cid}"
        end
      rescue
        puts $!
      end
    end
  end
  
  # container
  namespace :image do
    desc "list images"
    task :list do
      begin
        sh "docker images --all"
      rescue
        puts $!
      end
    end

    desc "clean (remove) untagged containers"
    task :clean, :cid do |t,arg|
      begin
        if arg.cid.nil?
          sh "docker images --all | egrep '^<none>' | awk '{print $3}' | xargs docker rmi --force"
        else
          sh "docker rmi --force #{arg.cid}"
        end
      rescue
        puts $!
      end
    end
  end

  namespace :daemon do
    desc 'restart docker daemon'
    task :restart do
      sh 'sudo service docker restart'
    end

    desc 'stop docker daemon'
    task :stop do
      sh 'sudo service docker stop'
    end

    desc 'start docker daemon'
    task :start do
      sh 'sudo service docker start'
    end
  end

  namespace :install do
    DOCKER_LIST = '/etc/apt/sources.list.d/docker.list'

    desc 'install docker pkg'
    task :pkg => [:keychain, :repo, :update, :install]

    desc "apt-get install lxc-docker"
    task :install do
      sh "sudo apt-get install -y lxc-docker"
    end

    desc "apt-get update"
    task :update do
      sh "sudo apt-get update -y"
    end

    desc 'repo source'
    task :repo do
      unless File.exists? DOCKER_LIST
        sh "sudo sh -c 'echo deb https://get.docker.io/ubuntu docker main > #{DOCKER_LIST}'"
      end
    end

    desc "add docker-repo keychain"
    task :keychain do
      sh "sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 36A1D7869245C8950F966E92D8576A8BA88D21E9"
    end
  end
end
