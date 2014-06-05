namespace :cluster do
    desc "start a cluster on dev for testing"
    task :start do
        nodes = [{role:'queue',num_actors:1},{role:'server',num_actors:1},{role:'client',num_actors:1}]
        Dir.chdir(SRC_DIR) do
            nodes.each do |n| 
                role = n[:role]
                n[:num_actors].times{|i|sh terminal("bundle exec rake run[--role=#{role}]",n[:role],"#{i}: #{n[:role]}")}
            end
        end
    end

    desc "add an actor to the cluster started via rake cluster:start"
    task :add, [:role,:num_actors] do |t,arg|
        raise "arg.role is undefined" if arg.port.nil?
        sh "#{SRC_DIR}/Main slave localhost #{arg.port} &"
    end
end
