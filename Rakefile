require File.expand_path("#{File.dirname(__FILE__)}/lib/task/dev.rb")

ENV['HOME'] = PROJ_DIR # hack to keep .cabal under this project dir.

Dir.glob("#{PROJ_HOME}/lib/task/*.rake"){|p| import p}

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
