namespace :run do
  desc "run main"
  task :main, [:opts] do |t,arg| 
    arg.with_defaults(opts: "./Main #{arg.opts}".strip)
    puts SRC_DIR.green
    Dir.chdir(SRC_DIR) do
      sh arg.opts
    end
  end

  desc "run spec"
  task :spec, [:opts] do |t,arg| 
    arg.with_defaults(opts: "./Spec #{arg.opts}".strip)
    puts SRC_DIR.green
    Dir.chdir(SRC_DIR) do
      sh arg.opts
    end
  end

  desc "run apache bench against Main"
  task :ab, [:clients,:requests,:url, :opts] do |t,arg| 
    arg.with_defaults(clients: 100, requests: 100000, url: 'http://localhost:8080/')
    sh "ab -c #{arg.clients} -n #{arg.requests} #{arg.opts} #{arg.url}"
  end
end
