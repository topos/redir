namespace :mesos do
  desc "install"
  task :install => 'mesos:_install:default'

  desc "build"
  task :build => 'mesos:_install:build'

  desc "clean"
  task :clean => 'mesos:_install:clean'

  desc "clean"
  task :clobber => 'mesos:_install:clobber'

  namespace :_install do
    MESOS_VER = '0.19.0'
    MESOS_URL = "http://www.apache.org/dist/mesos/#{MESOS_VER}/mesos-#{MESOS_VER}.tar.gz"
    MESOS_TAR = "/var/tmp/#{MESOS_URL.split('/').last}"
    MESOS_DIR = MESOS_TAR.split('.').first(MESOS_TAR.split('.').size-2).join('.')

    task :default => :install

    desc "install mesos from source"
    task :install => [:pkgs, :build]
    
    # build from source
    #task :build => [MESOS_DIR]

    task :build => MESOS_DIR do
      Dir.chdir "#{MESOS_DIR}/build" do
        sh "../configure --prefix=/opt/mesos CFLAGS=-O2 CXXFLAGS=-O2"
        sh "make -j 4"
        sh 'rake mesos:check'
      end
    end

    task :check do
    ls  sh "cd #{MESOS_DIR} && make check"
    end

    directory MESOS_DIR => MESOS_TAR do |t| 
      sh "cd /var/tmp && tar xf #{MESOS_TAR}"
      sh "mkdir -p #{MESOS_DIR}/build"
    end

    file MESOS_TAR do |t|
      sh "wget --output-document='#{MESOS_TAR}' #{MESOS_URL}"
    end

    task :clean do
      Dir.chdir MESOS_DIR do
        sh "make clean"
      end
    end

    task :clobber do
      [MESOS_TAR,MESOS_DIR].each do |d|
        sh "rm -rf #{d}"
      end
    end

    packages = {}
    packages['ubuntu'] = %w(autoconf libtool build-essential oracle-java8-installer python-dev python-boto libcurl4-nss-dev libsasl2-dev libprotobuf-dev libprotobuf-java maven)
    task :pkgs do
      install_pkg(packages[sys_name])
    end
  end
end
