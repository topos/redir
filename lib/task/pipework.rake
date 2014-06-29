namespace :pipework do
  desc 'install pipework (SDN)'
  task :install do
    Dir.chdir('/var/tmp') do
      sh "git clone https://github.com/jpetazzo/pipework.git"
      sh "mkdir -p #{ENV['HOME']}/bin"
      sh "cp /var/tmp/pipework/pipework #{ENV['HOME']}/bin"
    end
  end
end
