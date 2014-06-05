namespace :ghc do
  GHC_URL = 'http://www.haskell.org/ghc/dist/7.6.3/ghc-7.6.3-src.tar.bz2'
  GHC_TAR = "/var/tmp/#{GHC_URL.split('/').last}"
  GHC_DIR = "/var/tmp/#{GHC_URL.split('/').last.split('-src').first}"

  desc "install ghc from source"
  task :install => [:build] do
    sh "cd #{GHC_DIR} && sudo make install"
  end

  task :build => [:pkgs, GHC_DIR] do
    sh "cd #{GHC_DIR} && make -j 8"
  end

  task :pkgs do
    sh "sudo apt-get install -y ncurses-dev"
  end

  directory GHC_DIR => GHC_TAR do |t|
    sh "cd /var/tmp && tar xf #{GHC_TAR}"
    sh "cd #{GHC_DIR} && ./configure --prefix=/opt/ghc CFLAGS=-O2"
  end

  file GHC_TAR do |t|
    sh "wget -c -O #{t.name} #{GHC_URL}"
  end

  task :clean do
    [GHC_TAR,GHC_DIR].each do |d|
      sh "rm -rf #{d}"
    end
  end
end
