namespace :docker do
  task :start, [:name,:debug,:opts] do |t,arg|
    raise ":name of image is nil" if arg.name.nil?
    cmd = []
    cmd << 'docker run'
    cmd << arg.opts
    if arg.debug.nil? || arg.debug == ''
      cmd << '--detach'
    else
      cmd << '--interactive'
      cmd << '--user=root'
      cmd << '--entrypoint=/bin/bash'
    end
    cmd << arg.name
    sh cmd.join ' '
  end

  desc 'run bash within a container'
  task :sh, [:cmd,:image] do |t,arg|
    arg.with_defaults(image:'ubuntu')
    if arg.cmd.nil?
      sh "docker run -i -t #{arg.image} /bin/bash"
    else
      sh "docker run -i -t #{arg.image} '#{arg.cmd}'"
    end
  end

  desc 'make container: docker_dir in lib/docker'
  task :mk, [:name] do |t,arg|
    raise "no docker_dir arg.".red if arg.name.nil?
    docker_dir = "#{PROJ_DIR}/lib/docker/#{arg.name}"
    Dir.chdir docker_dir do
      sh "docker build --rm --tag=#{arg.name} ."
    end
  end

  desc 'docker dirs'
  task :dirs do
    puts "#{LIB_DIR}/docker".green
    `ls -1 #{LIB_DIR}/docker`.split.each do |l|
      puts '  ' + l.yellow
    end
  end
  task :images => :dirs

  desc 'info'
  task :info do
    v = `docker --version`.strip
    puts "#{v}".cyan
    d = `which docker`.strip
    puts "#{d}".green
    task :start, [:name,:opts,:debug] do |t,arg|
      raise ":name of image is nil" if arg.name.nil?
      cmd = []
      cmd << 'docker run'
      cmd << arg.opts
      if arg.debug.nil?
        cmd << '--detach'
      else
        cmd << '--interactive'
        cmd << '--user=root'
        cmd << '--entrypoint=/bin/bash'
      end
      cmd << arg.name
      sh cmd.join ' '
    end


    msg = <<EOF
for memory and swap accounting, run the following:
  if you want to enable memory and swap accounting, you must add the following 
  command-line parameters to your kernel:

  $ cgroup_enable=memory swapaccount=1

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

  desc "list containers"
  task :list do
    sh "docker ps --all"
  end
  task :ls => :list

  desc "stop all or an individual container"
  task :stop, [:cid] do |t,arg|
    if arg.cid == 'all' || arg.cid.nil?
      sh "docker stop $(docker ps --all --quiet)"
    else
      sh "docker stop #{arg.cid}"
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
