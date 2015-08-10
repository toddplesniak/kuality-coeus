require 'cucumber'
require 'cucumber/rake/task'

Cucumber::Rake::Task.new(:jenkins_with_rerun) do |t|
  t.cucumber_opts = '-t @test -f rerun --out rerun.txt'
end