namespace :run do
  task :default, [:cmd,:opts] do |t,arg| 
    arg.with_defaults(cmd:'Main', opts:'')
    cmd = "#{arg.cmd} #{arg.opts}".split.map{|e|e.strip}.join(' ')
    puts PROJ_DIR.green
    Dir.chdir(PROJ_DIR) do
      sh "./src/#{cmd}"
    end
  end

  desc "run main"
  task :main, [:opts] do |t,arg| 
    task('run:default').reenable
    task('run:default').invoke('Main', arg.opts)
  end

  desc "run spec"
  task :spec, [:opts] do |t,arg| 
    task('run:default').reenable
    task('run:default').invoke('Spec', arg.opts)
  end

  desc "run redir"
  task :redir, [:debug,:opts] do |t,arg|
    if arg.debug.nil? || arg.debug == ''
      sh "docker run --detach --tty --publish 127.0.0.1:8080:8080 redir"
    else
      sh "docker run --attach --tty --publish 127.0.0.1:8080:8080 redir"
    end
  end

  desc "curl"
  task :curl, [:url] do |t,arg| 
    arg.with_defaults(url: 'http://localhost:8080/')
    sh "curl -D - -o - #{arg.url}"
  end

  desc "run apache bench against Main"
  task :ab, [:clients,:requests,:url, :opts] do |t,arg| 
    arg.with_defaults(clients: 100, requests: 100000, url: 'http://localhost:8080/')
    sh "ab -c #{arg.clients} -n #{arg.requests} #{arg.opts} #{arg.url}"
  end
end
