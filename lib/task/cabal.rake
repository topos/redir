# cabal:init seems to create ~/.ghc directory in addiction to .cabal (i dunno)
namespace :cabal do
  desc "install cabal-sandbox packages"
  task :install, [:cabal] => [:init] do |t,arg|
    arg.with_defaults(opts: '')
    pkgs = `rake cabal:list`.split("\n").map{|l|l.strip.split.join('-')}
    Dir.chdir(PROJ_DIR) do
      pkg_list = []
      File.readlines('./lib/cabal.list').map{|l|l.strip}.each do |cabal_pkg|
        next if cabal_pkg =~ /^\s*#.*$/ || cabal_pkg =~ /^\s*$/
        cabal, pkgs = cabal_pkg.split('|')
        sh "sudo apt-get install -y #{pkgs}" unless pkgs.nil? || pkgs == ""
        cabals = `cabal list --installed --simple-output`.split("\n").map{|l|l.split.join('-')}
        unless cabals.include?(cabal)
          pkg_list << cabal
        else
          puts "#{cabal} " + "already installed".yellow
        end
      end
      if pkg_list.size > 0
        sh "cabal update"
        pkg_list.each do |pkg|
          #sh "cabal --allow-newer=P install #{pkg}"
          sh "cabal install #{pkg}"
        end
      end
    end
  end

  desc "remote cabal list"
  task :rlist, [:cabal] do |t,arg|
    task('cabal:list').invoke(arg.cabal,'r')
  end

  desc "list cabal-sandbox packages"
  task :list, [:cabal,:remote] do |t,arg|
    Dir.chdir(PROJ_DIR) do
      if arg.cabal.nil?
        sh "cabal list --verbose --installed --simple-output"
      else
        if arg.remote.nil?
          sh "cabal list --verbose --installed --simple-output #{arg.cabal}"
        else
          sh "cabal list --verbose --simple-output #{arg.cabal}"
        end
      end
    end
  end

  desc "update each cabal in lib/cabal.list"
  task :update_list do
    Dir.chdir(LIB_DIR) do
      list = File.open('cabal.list').read
      list.gsub!(/\s*\r\n?/, "\n")
      list.each_line do |l|
        unless l =~ /^\s*#/
          cab_elems = l.split('|').first.split('-')
          version, cabal = cab_elems.pop.strip, cab_elems.map{|e|e.strip}.join('-')
          l = cabal_list(cabal)
          if l.last.first == cabal
            if l[-1].last == version
              puts "current: " + "#{l.last.first}-#{l.last.last}".green
            else
              puts "#{l.last.first}-#{l.last.last} | #{cabal}-#{version} (local version)".yellow
            end
          end
        end
      end
    end
  end

  # cabal/version pairs: [[cabal,version],...]
  def cabal_list(cabal)
    l = []
    `cabal list --verbose --simple-output #{cabal}`.each_line do |line|
      elems = line.split(/\s+/)
      if cabal == elems.first
        l << elems unless elems.empty?
      end
    end
    l
  end
  
  desc "init. your cabal sandbox"
  task :init, [:force] do |t,arg|
    unless Dir.exists?("#{PROJ_DIR}/.cabal-sandbox") && arg[:force].nil?
      Dir.chdir(PROJ_DIR) do
        task('cabal:sandbox').invoke
        task('cabal:install').invoke
        # NB: may be able to remove PROJ_DIR/.cabal--everything is .cabal-sandbox
      end
    end
  end

  task :sandbox do
    sh "cabal update"
    sh "cabal install cabal-install"
    sh "cabal sandbox init"
  end

  task :add_src, [:src] do |t,arg|
    sh "cabal sandbox add-source #{arg.src}"
  end

  task :compile_cabal do
    Dir.chdir('/var/tmp') do
      sh "wget http://www.haskell.org/cabal/release/cabal-1.18.1.2/Cabal-1.18.1.2.tar.gz"
      sh "tar xpf Cabal-1.18.1.2.tar.gz"
      Dir.chdir('Cabal-1.18.1.2') do
        sh "ghc --make Setup"
        sh "./Setup configure --global --prefix=/opt/ghc"
        sh "./Setup build"
        sh "./Setup install"
      end
    end
  end

  namespace :cabal_install do
    task :install_from_src do
      VERSION = '1.18.0.3'
      CABAL_INST = "cabal-install-#{VERSION}"
      Dir.chdir('/var/tmp') do
        sh "wget http://www.haskell.org/cabal/release/#{CABAL_INST}/#{CABAL_INST}.tar.gz"
        sh "tar xpf #{CABAL_INST}.tar.gz"
        Dir.chdir(CABAL_INST) do
          sh "ghc --make Setup"
          sh "./Setup configure --global --prefix=/opt/ghc"
          sh "./Setup build"
          sh "./Setup install"
        end
      end
    end
  end

  desc "install only dependencies"
  task :install_deps => :install_dependencies
  task :install_dependencies do
    sh "cabal install --only-dependencies"
  end

  desc "info"
  task :info do
    version('cabal')
  end

  desc "clobber: clean slate"
  task :clobber => [:clobber_sandbox]

  desc "clobber (remove) your cabal sandbox"
  task :clobber_sandbox do
    begin
      if Dir.exists? SANDBOX_DIR
        Dir.chdir(PROJ_DIR) do
          sh "cabal sandbox delete || exit 0"
        end
      else
        puts "#{SANDBOX_DIR} doesn't exist".red
        puts "explicitly removing cabal sandbox".yellow
      end
    ensure
      sh "rm -rf #{SANDBOX_DIR}"
      sh "rm -f #{PROJ_DIR}/cabal.sandbox.config"
    end
  end
end
