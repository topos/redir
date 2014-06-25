namespace :docker do
  desc 'restart docker daemon'
  task :restart do
    sh 'sudo service docker restart'
  end

  desc 'restart docker daemon'
  task :stop do
    sh 'sudo service docker stop'
  end

  desc 'restart docker daemon'
  task :start do
    sh 'sudo service docker start'
  end

  # semantically similiar to its Dockerfile
  desc "make a docker container for redir"
  task :redir do
    sh "sudo rm -rf /var/tmp/redir"
    sh "mkdir -p /var/tmp/redir"
    sh "cp #{SRC_DIR}/Main /var/tmp/redir/redird"
    sh "cp #{ETC_DIR}/redirect.yml /var/tmp/redir/"
    sh "cp #{LIB_DIR}/docker/redir/Dockerfile /var/tmp/redir/"
    task('docker:mk').invoke('/var/tmp/redir','redir')
  end

  desc 'list conainers'
  task :list, [:ltype] do |t,arg|
    arg.with_defaults(ltype:'c') # (c)ontainer or (i)mage
    ltype = arg.ltype[0].downcase
    case ltype
    when 'c'
      sh "docker ps --all"
    when 'i'
      sh "docker images --all"
    else
      raise $!
    end
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

  desc 'make container'
  task :mk, [:docker_dir,:name] do |t,arg|
    raise "no docker_dir arg.".red if arg.docker_dir.nil?
    arg.with_defaults(name: arg.docker_dir)
    Dir.chdir arg.docker_dir do
      sh "sudo docker build -t=#{arg.name} ."
    end
  end

  desc 'list of docker files'
  task :files do
    sh "ls #{LIB_DIR}/docker"
  end

  desc 'info'
  task :info do
    sh "which docker", :verbose => false
    sh "docker --version", :verbose => false
    sh "docker version"
    puts "---".green
    puts <<EOF
Memory and Swap Accounting
If you want to enable memory and swap accounting, you must add the following 
command-line parameters to your kernel:

$ cgroup_enable=memory swapaccount=1

Add the above parameters by editing /etc/default/grub and extending 
GRUB_CMDLINE_LINUX. Look for the following line:

$ GRUB_CMDLINE_LINUX=""
p
And replace it with the following:
$ GRUB_CMDLINE_LINUX="cgroup_enable=memory swapaccount=1"

$ sudo update-grub
$ reboot
EOF
  end

  desc "non-root (user) access"
  task :user_access do
    sh "sudo groupadd docker || exit 0"
    sh "sudo gpasswd -a #{ENV['LOGNAME']} docker"
    puts "type rake docker:restart".red
  end

  desc 'install docker'
  task :install => 'docker:install:pkg'

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
