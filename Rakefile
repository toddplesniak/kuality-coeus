require 'cucumber'
require 'cucumber/rake/task'
require 'json'

namespace :jenkins do

  task :full_with_rerun do
    zen_garden 'jenkins', 'full_suite'
  end

  task :smoke_with_rerun do
    zen_garden 'jenkins', 'smoke_suite'
  end

  Cucumber::Rake::Task.new(:full_suite) do |t|
    t.cucumber_opts = 'features -b -t ~@wip -t ~@smoke -t ~@performance -t ~@system_failure --format rerun --out rerun.txt --expand -r features --format json -o first_run.json'
  end

  Cucumber::Rake::Task.new(:smoke_suite) do |t|
    t.cucumber_opts = 'features --expand -t @smoke -t ~@wip -t ~@system_failure --format rerun --out rerun.txt -r features --format json -o first_run.json -b'
  end

  Cucumber::Rake::Task.new(:rerun_failed) do |t|
    t.cucumber_opts = '@rerun.txt -b --expand -r features --format json -o rerun.json -b --strict'
  end

end

namespace :vagrant do

  task :full_with_rerun do
    zen_garden 'vagrant', 'full_suite'
  end

  task :smoke_with_rerun do
    zen_garden 'vagrant', 'smoke_suite'
  end

  task :test_with_rerun do
    zen_garden 'vagrant', 'test'
  end

  Cucumber::Rake::Task.new(:test) do |t|
    t.cucumber_opts = '/kuality-coeus/features -b -t @test --format rerun --out rerun.txt --expand -r /kuality-coeus/features --format json -o first_run.json'
  end

  Cucumber::Rake::Task.new(:full_suite) do |t|
    t.cucumber_opts = '/kuality-coeus/features -b -t ~@wip -t ~@smoke -t ~@performance -t ~@system_failure --format rerun --out rerun.txt --expand -r /kuality-coeus/features --format json -o first_run.json'
  end

  Cucumber::Rake::Task.new(:smoke_suite) do |t|
    t.cucumber_opts = '/kuality-coeus/features --verbose --expand -t @smoke -t ~@wip -t ~@system_failure --format rerun --out rerun.txt -r /kuality-coeus/features --format json -o first_run.json'
  end

  Cucumber::Rake::Task.new(:rerun_failed) do |t|
    t.cucumber_opts = '@rerun.txt -r /kuality-coeus/features -b --expand --verbose --strict --format json -o rerun.json'
  end

end

def remove_files *args
  args.each { |arg| FileUtils.rm_f(arg) if File.exist?(arg) }
end

def decapitate
  if ENV['HEADLESS']
    require 'headless'
    display = Time.now.to_i
    Headless.new(display: display, reuse: true, destroy_at_exit: true).start
  end
end

def zen_garden(space, task)
  decapitate
  rr = 'rerun.txt'
  remove_files rr, 'cucumber.json', 'cucumber_clean.json', 'cucumber_fix.json', 'screenshot.png', 'rerun.json', 'first_run.json'
  rescued = false
  begin
    Rake::Task["#{space}:#{task}"].invoke
  rescue Exception => e
    clean_first_run
    rescued = true
    if File.exist? rr
      rerun_features = IO.read(rr)
      begin
        Rake::Task["#{space}:rerun_failed"].invoke unless rerun_features.to_s.strip.empty?
      rescue Exception => x
        # No need to do anything except stop the non-zero exit
      end
      clean_rerun
    end
  end
  unless rescued
    FileUtils.mv 'first_run.json', 'cucumber.json'
  end
end

# JSON Parser methods...

def clean_first_run
  rep = 'first_run.json'
  if File.exist? rep
    cuke = IO.read rep
    features = JSON.parse cuke
    failures = []
    features.each do |feature|
      statuses = []
      feature['elements'].each do |element|
        statuses << element['steps'].map { |s| s['result']['status'] }
      end
      statuses.flatten!
      if statuses.include?('failed') || statuses.include?('skipped')
        failures << feature
      end
    end
    passed = features - failures
    failing = JSON.pretty_generate failures
    passing = JSON.pretty_generate passed
    File.write 'cucumber_clean.json', passing
    File.write 'first_run_failures.json', failing
  end
end

def clean_rerun
  rep = 'rerun.json'
  cuke = IO.read rep
  features = JSON.parse cuke
  features.each do |feature|
    feature['elements'].each do |element|
      if element.has_key? 'after'
        if element['after'][0].has_key? 'embeddings'
          screenshot = element['after'][0]['embeddings']
          failed_step = element['steps'].find { |step| step['result']['status']=='failed' }
          if failed_step.nil?
            failed_step = element['steps'][-1]
            failed_step['result']['status'] = 'failed'
          end
          failed_step.store('embeddings', screenshot)
          element['after'][0].delete 'embeddings'
        end
      end
    end
  end
  json = JSON.pretty_generate features
  File.write 'cucumber_fix.json', json
end