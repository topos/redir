require File.expand_path("#{File.dirname(__FILE__)}/lib/task/dev.rb")

ENV['HOME'] = PROJ_DIR # hack to keep .cabal under this project dir.

Dir.glob("#{PROJ_HOME}/lib/task/*.rake"){|p| import p}

desc "start src development".green
task :cc => 'dev:start'

desc "compile/link code".green
task :c => 'dev:all'

desc "test code".green
task :t => :test

task :start => 'dev:start'
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


