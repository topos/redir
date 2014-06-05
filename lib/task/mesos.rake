namespace :mesos do
  desc "install"
  task :install => 'mesos:_install:default'

  desc "build"
  task :build => 'mesos:_install:build'

  desc "clean"
  task :clean => 'mesos:_install:clean'

  namespace :_install do
    ENV['JAVA_HOME'] = '/usr/lib/jvm/default-java'
    MESOS_VER = '0.18.2'
    MESOS_URL = "http://www.apache.org/dist/mesos/#{MESOS_VER}/mesos-#{MESOS_VER}.tar.gz"
    MESOS_TAR = "/var/tmp/#{MESOS_URL.split('/').last}"
    MESOS_DIR = MESOS_TAR.split('.').first(MESOS_TAR.split('.').size-2).join('.')

    task :default => :install

    desc "install mesos from source"
    task :install => [:pkgs, :build]
    
    # build from source
    #task :build => [MESOS_DIR]

    task :build => MESOS_DIR do
      sh "cd #{MESOS_DIR} && make -j 4"
      sh 'rake mesos:check'
    end

    task :check do
      sh "cd #{MESOS_DIR} && make check"
    end

    directory MESOS_DIR => MESOS_TAR do |t| 
      sh "cd /var/tmp && tar xf #{MESOS_TAR}"
      sh "cd #{MESOS_DIR} && ./configure --prefix=/opt/mesos CFLAGS=-O2"
    end

    file MESOS_TAR do |t|
      sh "wget --output-document='#{MESOS_TAR}' #{MESOS_URL}"
    end

    task :clean do
      [MESOS_TAR,MESOS_DIR].each do |d|
        sh "rm -rf #{d}"
      end
    end

    packages = {}
    packages['ubuntu'] = %w(autoconf libtool build-essential oracle-java8-installer python-dev python-boto libcurl4-nss-dev libsasl2-dev libprotobuf-dev libprotobuf-java)
    task :pkgs do
      install_pkg(packages[sys_name])
    end
  end
end
