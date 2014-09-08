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

  desc "curl"
  task :curl, [:url,:req] do |t,arg| 
    arg.with_defaults(url: 'http://localhost:8080/', req:'get')
    sh "curl --#{arg.req} -o - #{arg.url}"
  end

  desc "http get"
  task :get, [:uri,:host_port,:proto] do |t,arg| 
    arg.with_defaults(host_port:'localhost:8080',uri:'/',proto:'http')
    sh "curl -D - -o - #{arg.proto}://#{arg.host_port}/#{arg.uri}"
  end

  desc "run apache bench against Main"
  task :ab, [:clients,:requests,:url, :opts] do |t,arg| 
    arg.with_defaults(clients: 100, requests: 1000000, url: 'http://localhost:8080/')
    sh "ab -c #{arg.clients} -n #{arg.requests} #{arg.opts} #{arg.url}"
  end
end
