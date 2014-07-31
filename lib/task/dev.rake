# -*- coding: utf-8 -*-
namespace :dev do
  desc "start"
  task :start do
    require 'listen'
    Dir.chdir(SRC_DIR) do
      make_spec
      make_all
      @listener = Listen.to('.', relative_path: true, filter: /(\.hs$|\/Main$|\/Spec$)/) do |modified,added,removed|
        make_spec
        make_all
      end
      @listener.start
      trap('SIGINT') {@listener.stop; exit}
      sleep
    end
  end

  task :all do
    Dir.chdir(SRC_DIR) do
      make_spec
      make_all
    end
  end

  desc "run all tests (specs)"
  task :test => :spec

  desc "run specs"
  task :spec do
    sh "cd #{SRC_DIR} && ./Spec"
  end

  desc "build app"
  task :build, [:dev] do |t,arg|
    puts "@todo: implement".red
  end

  desc "install app"
  task :install, [:dir,:name] do |t,arg|
    arg.with_defaults dir:'/var/tmp/redir', name:'redir'
    sh "cp -a #{SRC_DIR}/Main #{arg.dir}/#{arg.name}"
  end

  desc "clean"
  task :clean, [:dev] do |t,arg|
    Dir.chdir SRC_DIR do
      fs = FileList.new(['*Spec','*.o','*.hi','*.hc'].map{|g|"./**/#{g}"})
      sh "rm -f Main #{fs.join(' ')}"
    end
  end

  desc "ghci"
  task :ghci do
    unless Dir.exists?(File.expand_path('~/.ghci'))
      File.open(File.expand_path('~/.ghci'),'w'){|f|f.write(dot_ghci)}
    end
    Dir.chdir("#{PROJ_HOME}/lib") do
      sh "export GHC_PACKAGE_PATH=#{GHC_PACKAGE_PATH}:; ghci -cpp"
    end
  end

  desc "graphical rep. of \"git diff\""
  task :diff, [:csv] do |t,arg|
    arg.with_defaults(csv: "")
    if arg[:csv].empty?
      sh "gdiff"
    else
      arg[:csv].split.each{|f| sh "gdiff #{f}"}
    end
  end

  desc "init dev. env.: cabal-dev install"
  #task :init => [:gems, 'zmq:install'] do
  task :init => [:gems,:dist] do
    sh "mkdir -p #{DIST_DIR}/redir"
    task('cabal:init').invoke
  end

  desc "install packages"
  task :pkgs do
    PS = [] << 'libdevil-dev'
    PS << 'llvm-dev'
    PS << 'openvswitch-switch'
    PS << 'openvswitch-controller'
    PS << 'qemu-kvm' 
    PS << 'libvirt-bin'
    sh "sudo apt-get update -y"
    sh "sudo apt-get install -y #{PS.join(' ')}"
  end

  desc "reset (remove cabal-dev) dev. env."
  task :reset => [:clean] do
    task('cabal:clean').invoke
  end

  desc "install gems"
  task :gems do
    gems = [] << ['smart_colored','1.1.1']
    gems << ['sys-proctable','0.9.3']
    gems << ['listen','1.3.0']
    gems.each do |gem,version|
      sh "gem list --installed --version=#{version} #{gem}" do |ok,res|
        if ok
          puts "#{gem}-#{version} " + "already installed".green
        else
          sh "sudo gem install --no-ri --no-rdoc --version=#{version} #{gem}"
        end
      end
    end
  end

  desc "update dev env., e.g.: cabal:update"
  task :update do
    sh "rake cabal:update"
  end

  desc "clean: rm -rf ./dist/*"
  task :clean do
    sh "rm -rf #{PROJ_HOME}/dist/*"
  end

  desc "info"
  task :info do
    puts PROJ_HOME.red
    puts "- PATH=#{ENV['PATH']}".yellow
    puts "- GHC=#{GHC}".cyan
    ['ghc','cabal'].each{|c|version(c)}
  end

  # cabal may not be needed--static compilation may not require external packages
  def cabal(arg)
    arg.with_defaults(:dev => 'dev')
    if arg[:dev] == 'prod'
      'cabal'
    else
      'cabal-dev'
    end
  end

  desc "rsync/init a GHC project"
  task :rsync_proj, [:proj_name,:delete] do |t,arg|
    arg.defaults(delete:'false')
    PROJ_DIR = File.expand_path("#{File.dirname(__FILE__)}/../../../.")
    Dir.chdir(PROJ_DIR) do
      sh "mkdir -p arg.proj_name"
      rsync = [] << "rsync -axv --exclude .git --exclude '*~*'"
      if arg.delete =~ /^(del|delete)$/
        rsync << '--delete --delete-excluded'
      end
      rsync << "#{PROJ_HOME}/"
      rsync << "#{PROJ_DIR}/#{arg.proj_name}/"
      sh "#{rsync.join(' ')}"
    end
    Dir.chdir("#{PROJ_DIR}/#{arg.proj_name}") do
      ['bin','etc','src'].each do |dir|
        sh "mkdir -p #{dir}" unless Dir.exists?(dir)
      end
      sh "git init" unless Dir.exists?('.git')
    end
  end

  def make_all
    make
  end

  def make_spec
    make(src_files(spec_too=true), 'Spec')
  end

  def make(src =src_files, name ='Main')
    ghc_cmd = "#{GHC} --make #{src} -o #{name} #{EXTRA_LIB} -optl-Wl,-rpath,'#{EXTRA_LIB_DIR}' 2>&1"
    #puts ghc_cmd.red
    IO.popen(ghc_cmd) do |io|
      Process.wait(io.pid)
      status = $? == 0
      putsh(status, io.readlines.select{|l|l.size > 0}, name)
      sh "rm -f #{name}" unless status
      io.close
    end
  end

  def compiler(src)
    FileList[src].ext('o').each{|f|File.delete(f) if File.exists?(f)}
    (src.class == String ? [src] : src).each do |f|
      puts "#{GHC} -c #{f}".yellow
      IO.popen("#{GHC} -c #{f} 2>&1") do |io|
        Process.wait(io.pid)
        putsh($? == 0, io.readlines.select{|l|l.size > 0}, __callee__)
        io.close
        if $? != 0
          puts "status=#{$?}"
          return false
        end
      end
    end
    true
  end

  def putsh(ok, res, app_name)
    if ok
      r = []
      r << "+ make".green + " ./src/#{app_name} " + "succeeded".green + " @#{DateTime.now.strftime('%H:%M:%S')}\n"
    else
      r = res.map{|l|l.yellow}
      r << "- make".red + " ./src/#{app_name} " + "failed".red + " @#{DateTime.now.strftime('%H:%M:%S')}\n"
    end
    r.each{|l|print l}
  end

  def dot_ghci
    <<EOF
import Control.Applicative
import Control.Monad
import Control.Concurrent
import Control.Concurrent.Async
import Control.Parallel

import Data.String
import Data.Char
import Data.List
import Data.Monoid
import Control.Monad.IO.Class

:set prompt "λ: "

:set -fno-warn-unused-imports
:def hlint const . return $ ":! hlint \\"src\\""
:def hoogle \\s -> return $ ":! hoogle --count=15 \\"" ++ s ++ "\\""
:def pl \\s -> return $ ":! pointfree \\"" ++ s ++ "\\""
EOF
  end
end
