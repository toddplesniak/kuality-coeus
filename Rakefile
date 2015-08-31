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
    display = Time.now.to_i.to_s[7..-1]
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
    # Delete the failing scenarios...
    features.each do |feature|
      feature['elements'].delete_if do |element|
        step_statuses = element['steps'].map { |step| step['result']['status'] }
        true if step_statuses.include?('failed') || step_statuses.include?('skipped')
        case(element['type'])
          when 'background'
            true if element['before'][0]['result']['status']=='failed' || element['before'][0]['result']['status']=='skipped'
          when 'scenario'
            true if element['after'][0]['result']['status']=='failed' || element['after'][0].has_key?('embeddings')
          else
            raise "Element type #{element['type']} not accounted for. Please add this code."
        end
      end
    end
    # Extra "background" and "scenario" elements need to be deleted...
    features.each do |feature|
      next if feature['elements'].size < 2
      feature['elements'].each_with_index do |element, index|
        delete_it = case element['type']
                      when 'background'
                        true if feature['elements'][index+1].nil? || feature['elements'][index+1]['type']=='background'
                      when 'scenario'
                        true if feature['elements'][index-1].nil? || feature['elements'][index-1]['type']=='scenario'
                      else
                        raise "Element type #{element['type']} not accounted for. Please add this code."
                    end
        element['delete_me'] = 'yes' if delete_it
      end
      feature['elements'].delete_if { |element| element['delete_me']=='yes' }
    end
    features.delete_if { |f| f['elements'].empty? }
    passing = JSON.pretty_generate features
    File.write 'clean.json', passing
  end
end

def clean_rerun
  list = JSON.parse(IO.read('clean.json'))
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
  features.each do |feature|
    item = list.find { |item| item['id']==feature['id'] }
    if item
      feature['elements'].each { |e| item['elements'] << e }
    else
      list << feature
    end
  end
  json = JSON.pretty_generate list
  File.write 'cucumber.json', json
end