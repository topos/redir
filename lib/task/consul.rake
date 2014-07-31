namespace :consul do
  desc "install consul"
  task :install do
    urls = %w(https://dl.bintray.com/mitchellh/consul/0.3.1_linux_amd64.zip https://dl.bintray.com/mitchellh/consul/0.3.1_web_ui.zip)
    Dir.chdir('/var/tmp') do
      urls.each do |url|
        sh "wget #{url}"
        sh "unzip #{url.split('/').last}"
      end
    end
  end
end
