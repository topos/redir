require 'rubygems'
require 'bundler/setup'
require 'date'
require 'yaml'
require 'smart_colored/extend'

def sys_name
  s = `uname -s`.strip.downcase
  s = `lsb_release --id`.split.last.strip.downcase if 'linux' == s
  s
end

def sys_name?(p)
  sys_name == p.strip.downcase
end

def platform?(p)
  `uname -s`.strip.downcase == p.downcase
end

def proj_dir(subdir =nil)
  path = [] << PROJ_DIR
  path << subdir unless subdir.nil?
  path.join('/')
end

def process_running?(name, argfilter =nil)
  require 'sys/proctable'
  include Sys
  ProcTable.ps do |proc|
    if argfilter.nil?
      return true if proc.comm == name
    else
      return true if proc.comm == name && proc.cmdline.split.include?(argfilter)
    end
  end
  false
end

def proj_mode
  ENV['PROJ_MODE'].nil? ? 'Development' : ENV['PROJ_MODE']
end

def install_pkg(pkgs =[], sysname =sys_name)
  update, install = case sysname
                    when 'centos'
                      ['sudo yum update -y', 'sudo yum install -y']
                    when 'darwin'
                      ['brew update -y', 'brew install']
                    when 'ubuntu'
                      ['sudo apt-get update -y', 'sudo apt-get install -y']
                    else
                      raise "unknown system--not in {centos,darwin,ubuntu}"
                    end
  sh "#{update}"
  sh "#{install} #{pkgs.join(' ')}"
end

def src_files(spec_too =false)
  if spec_too
    FileList.new(SRC_DIR + '/**/*.hs').exclude(/Main\.hs$/).join(' ')
  else
    FileList.new(SRC_DIR + '/**/*.hs').exclude(/.*Spec\.hs$|Spec\.hs$/).join(' ')
  end
end

def version(bin, arg ='--version')
  puts `which #{bin}`.strip.green
  `#{bin} #{arg}`.split(/\n/).map{|l|puts "- #{l.strip}".yellow}
end

PROJ_DIR = File.expand_path("#{File.dirname(__FILE__)}/../../.")
SRC_DIR = proj_dir('src')
LIB_DIR = proj_dir('lib')
TASK_DIR = proj_dir('lib/task')
SANDBOX_DIR = proj_dir('.cabal-sandbox')
PROJ_HOME = PROJ_DIR
OPT_DIR = '/opt'

os = `uname -s`.strip.downcase
OS = case os
     when 'darwin'; 'osx'
     when 'linux'; 'linux'
     else raise "unknown OS: #{os}"
     end
GHC_VERSION = '7.8.2'
GHC_PACKAGE_PATH = "#{PROJ_DIR}/.cabal-sandbox/x86_64-#{OS}-ghc-#{GHC_VERSION}-packages.conf.d"
CABAL_SANDBOX_DIR = "#{PROJ_DIR}/.cabal-sandbox"
EXTRA_INC_DIR = "/opt/zmq/include"
EXTRA_LIB_DIR = "/opt/zmq/lib"
EXTRA_INC, EXTRA_LIB = ['#{EXTRA_INC_DIR}',"-L#{EXTRA_LIB_DIR} -lzmq"]
GHC_OPT = "-no-user-package-db -package-db #{PROJ_DIR}/.cabal-sandbox/*-#{GHC_VERSION}-packages.conf.d"
#GHC = "ghc #{GHC_PACKAGE_PATH.split.map{|p|"-package-db #{p}"}.join(' ')} -hide-package monads-tf -threaded"
GHC = "ghc #{GHC_OPT} -threaded"

# ~/.cabal/bin is important since the latest version of cabal-install will go there
_path = []
_path << "#{PROJ_DIR}/bin"
_path << "#{PROJ_DIR}/.cabal-sandbox/bin"
_path << (sys_name?('darwin') ? '/Users' : '/home') + "/#{ENV['LOGNAME']}/.cabal/bin"
_path << (sys_name?('darwin') ? '~/Library/Haskell/bin' : '/opt/ghc/bin')
_path << '/usr/local/bin'
_path << '/usr/bin'
_path << '/bin'

ENV['PATH'] = _path.join(':')
ENV['JAVA_HOME'] = '/usr/lib/jvm/java-8-oracle'
