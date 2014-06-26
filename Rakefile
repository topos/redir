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

namespace :app do
  desc "run redir"
  task :start_redir, [:debug,:opts] do |t,arg|
    if arg.debug.nil? || arg.debug == ''
      sh "docker run --detach --tty --publish 127.0.0.1:8080:8080 redir"
    else
      sh "docker run -i -t --entrypoint='/bin/bash' redir"
    end
  end

  desc "run mighttpd (mighty)"
  task :start_mighttpd, [:debug,:opts] do |t,arg|
    if arg.debug.nil? || arg.debug == ''
      sh "sudo docker run --detach --tty --publish 127.0.0.1:80:8080 mighttpd"
    else
      sh "docker run --interactive --tty --entrypoint=/bin/bash mighttpd"
    end
  end

  # semantically similiar to its ./lib/redir/Dockerfile
  desc "make a docker container for redir"
  task :redir => [:clean,:c] do
    sh "sudo rm -rf /var/tmp/redir"
    sh "mkdir -p /var/tmp/redir"
    sh "cp #{SRC_DIR}/Main /var/tmp/redir/redir"
    sh "cp #{ETC_DIR}/redir.yml /var/tmp/redir/redir.yml"
    sh "cp #{LIB_DIR}/docker/redir/Dockerfile /var/tmp/redir/"
    task('docker:mk').reenable
    task('docker:mk').invoke('/var/tmp/redir','redir')
  end

  # semantically similiar to its ./lib/redir/Dockerfile
  desc "make a docker container for redir"
  task :mighttpd do |t|
    sh "sudo rm -rf /var/tmp/#{t.name}"
    sh "mkdir -p /var/tmp/#{t.name}"
    sh "cp #{LIB_DIR}/docker/#{t.name}/* /var/tmp/#{t.name}/"
    # for generalization: some task here
    task('docker:mk').reenable
    task('docker:mk').invoke("/var/tmp/#{t.name}",t.name)
  end
end
