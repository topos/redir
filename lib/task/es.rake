namespace :es do
    ES = 'elasticsearch-0.90.3.deb'
    URL = "https://download.elasticsearch.org/elasticsearch/elasticsearch/#{ES}"

    desc "start elasticsearch"
    task :start do
        unless process_running?('java', 'org.elasticsearch.bootstrap.ElasticSearch')
            sh "sudo /etc/init.d/elasticsearch start"
        else
            puts "elasticsearch is already running".yellow
        end
    end 

    desc "stop elasticsearch"
    task :stop do
        if process_running?('java', 'org.elasticsearch.bootstrap.ElasticSearch')
            sh "sudo /etc/init.d/elasticsearch stop"
        else
            puts "elasticsearch isn't running".yellow
        end
    end

    desc "install elasticsearch"
    task :install => :download do
        sh "sudo dpkg --install #{ES}"
        Rake::Task['es:configure'].invoke
    end

    desc "configure"
    task :configure do
        unless File.executable?('/etc/init.d/elasticsearch')
            sh "sudo chmod +x /etc/init.d/elasticsearch"
        end
        Dir.chdir('/var/lib/elasticsearch') do
            if Dir.exists?('./elasticsearch')
                sh "sudo mv elasticsearch elasticsearch-#{`logname`.strip}"
            end
        end
    end

    desc "download #{ES}"
    task :download do
        sh "wget -c #{URL}"
    end

    desc "remove downloaded files"
    task :clean do
        sh "rm -f *.deb"
    end
end
