namespace :redir do
  task :default => :docker

  REDIR_DOCKER_DIR = "#{DOCKER_DIR}/redir"

  task :docker => [:clean,:install] do
    task('docker:mk').reenable
    task('docker:mk').invoke(REDIR_DOCKER_DIR.split('/').last)
  end

  task :install do
    Dir.chdir PROJ_DIR do
      ['dev:clean', 'dev:all', "dev:install[#{REDIR_DOCKER_DIR}]"].each do |t|
        sh "bundle exec rake #{t}"
        sh "cp #{ETC_DIR}/redir.yml #{REDIR_DOCKER_DIR}"
      end
    end
  end

  task :clean => 'dev:clean' do
    Dir.chdir REDIR_DOCKER_DIR do
      sh "rm -f redir redir.yml"
    end
  end
end
