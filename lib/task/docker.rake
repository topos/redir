namespace :docker do
  desc "restart docker daemon"
  task :restart do
    sh "sudo restart docker.io"
  end

  desc "run bash within a container"
  task :sh, [:cmd,:image] do |t,arg|
    arg.with_defaults(image:'ubuntu')
    if arg.cmd.nil?
      sh "docker run -i -t #{arg.image} /bin/bash"
    else
      sh "docker run -i -t #{arg.image} '#{arg.cmd}'"
    end
  end

  desc "make container"
  task :mk, [:dockerfile] do |t,arg|
    raise "no dockerfile arg.".red if arg.dockerfile.nil?
    sh "docker build -t brand_new_memcached - < #{LIB_DIR}/docker/#{arg.dockerfile}"
  end

  desc "list of docker files"
  task :files do
    sh "ls #{LIB_DIR}/docker"
  end#{PROJ_DIR}

  desc "example docker file"
  task :file do
    t = %q{
# Memcached
# VERSION 0.1
FROM ubuntu
MAINTAINER Victor Coisne victor.coisne@dotcloud.com

RUN echo "deb http://archive.ubuntu.com/ubuntu trusty main universe" > /etc/apt/sources.list
RUN apt-get update -y
RUN apt-get install -y memcached

ENTRYPOINT ["memcached"]
USER daemon
EXPOSE 11211
    }
    puts t.green
  end

  desc "install docker"
  task :install => 'docker:_install:default'
  namespace :_install do
    task :default => :install

    task :install => [:pkgs,:user_access] do
      sh "sudo ln -sf /usr/bin/docker.io /usr/local/bin/docker"
    end

    task :user_access do
      sh 'sudo groupadd --force docker'
      sh "sudo gpasswd -a #{ENV['USER']} docker"
      task('docker:restart').invoke
    end
  
    task :pkgs do
      ['apt-get update -y','apt-get install -y docker.io'].each do |c|
        sh "sudo #{c}"
      end
    end
  end
end
