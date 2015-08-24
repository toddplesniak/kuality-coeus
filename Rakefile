require 'cucumber'
require 'cucumber/rake/task'
require 'json'

namespace :jenkins do

  task :full_with_rerun do
    rerun = 'rerun.txt'
    remove_files rerun, 'cucumber.json', 'cucumber1.json'
    begin
      Rake::Task['jenkins:full_suite'].invoke
    rescue Exception => e
      clean_json_report
      if File.exist?(rerun)
        rerun_features = IO.read(rerun)
        begin
          Rake::Task['jenkins:rerun_failed'].invoke unless rerun_features.to_s.strip.empty?
        rescue Exception => x
          fix_embedded_images
        end
      end
    end
  end

  task :smoke_with_rerun do
    rerun = 'rerun.txt'
    remove_files rerun, 'cucumber.json', 'cucumber1.json'
    begin
      Rake::Task['jenkins:smoke_suite'].invoke
    rescue Exception => e
      clean_json_report
      if File.exist?(rerun)
        rerun_features = IO.read(rerun)
        begin
          Rake::Task['jenkins:rerun_failed'].invoke unless rerun_features.to_s.strip.empty?
        rescue Exception => x
          fix_embedded_images
        end
      end
    end
  end

  Cucumber::Rake::Task.new(:full_suite) do |t|
    t.cucumber_opts = 'features --order random -b -t ~@wip -t ~@smoke -t ~@performance -t ~@system_failure --format rerun --out rerun.txt --expand -r features --format json -o cucumber.json'
  end

  Cucumber::Rake::Task.new(:smoke_suite) do |t|
    t.cucumber_opts = 'features --expand -t @smoke -t ~@wip -t ~@system_failure --format rerun --out rerun.txt -r features --format json -o cucumber.json -b'
  end

  Cucumber::Rake::Task.new(:rerun_failed) do |t|
    t.cucumber_opts = '@rerun.txt -b --expand -r features --format json -o cucumber1.json -b --strict'
  end

end

namespace :vagrant do

  task :full_with_rerun do
    rerun = 'rerun.txt'
    remove_files rerun, 'cucumber.json', 'cucumber1.json'
    begin
      Rake::Task['vagrant:full_suite'].invoke
    rescue Exception => e
      clean_json_report
      if File.exist?(rerun)
        rerun_features = IO.read(rerun)

        # DEBUG
        puts
        puts 'In the rescue clause...'
        puts
        puts rerun_features
        puts
        begin
          Rake::Task['vagrant:rerun_failed'].invoke unless rerun_features.to_s.strip.empty?
        rescue Exception => x
          fix_embedded_images
        end
      end
    end
  end

  task :smoke_with_rerun do
    rerun = 'rerun.txt'
    remove_files rerun, 'cucumber.json', 'cucumber1.json'
    begin
      Rake::Task['vagrant:smoke_suite'].invoke
    rescue Exception => e
      clean_json_report
      if File.exist?(rerun)
        rerun_features = IO.read(rerun)

        # DEBUG
        puts
        puts 'In the rescue clause...'
        puts
        puts rerun_features
        puts
        begin
          Rake::Task['vagrant:rerun_failed'].invoke unless rerun_features.to_s.strip.empty?
        rescue Exception => x
          fix_embedded_images
        end
      end
    end
  end

  Cucumber::Rake::Task.new(:test) do |t|
    t.cucumber_opts = '/kuality-coeus/features -b -t @test --format rerun --out rerun.txt --expand -r /kuality-coeus/features'
  end

  Cucumber::Rake::Task.new(:full_suite) do |t|
    t.cucumber_opts = '/kuality-coeus/features -b -t ~@wip -t ~@smoke -t ~@performance -t ~@system_failure --format rerun --out rerun.txt --expand -r /kuality-coeus/features --format json -o cucumber.json'
  end

  Cucumber::Rake::Task.new(:smoke_suite) do |t|
    t.cucumber_opts = '/kuality-coeus/features --verbose --expand -t @smoke -t ~@wip -t ~@system_failure --format rerun --out rerun.txt -r /kuality-coeus/features --format json -o cucumber.json'
  end

  Cucumber::Rake::Task.new(:rerun_failed) do |t|
    t.cucumber_opts = '@rerun.txt -r /kuality-coeus/features -b --expand --verbose --strict --format json -o cucumber1.json'
  end

end

def clean_json_report
  rep = 'cucumber.json'
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
    json = JSON.pretty_generate passed
    File.write rep, json
  end
end

def fix_embedded_images
  rep = 'cucumber1.json'
  cuke = IO.read rep
  features = JSON.parse cuke
  features.each do |feature|
    feature['elements'].each do |element|
      if element.has_key? 'after'
        if element['after'][0].has_key? 'embeddings'
          screenshot = element['after'][0]['embeddings']
          failed_step = element['steps'].find { |step| step['result']['status']=='failed' }
          failed_step ||= element['steps'][-1]
          failed_step.store('embeddings', screenshot)
          element['after'][0].delete 'embeddings'
        end
      end
    end
  end
  json = JSON.pretty_generate features
  File.write rep, json
end

def remove_files *args
  args.each { |arg| FileUtils.rm_f(arg) if File.exist?(arg) }
end