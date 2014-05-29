namespace :run do
  desc "run Main or generally Spec"
  task :run, [:options] do |t,arg| 
    arg.with_defaults(options: "Main #{arg.options}".strip)
    puts SRC_DIR.green
    Dir.chdir(SRC_DIR) do
      sh "./#{arg.options}"
    end
  end
end
