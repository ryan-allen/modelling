task :default do
  Rake::Task['run_tests'].invoke
end

task :run_tests do 
  require 'modelling_test'
end
