require 'yaml'
require 'watir-webdriver'

$base_url = ENV['URL']
$context = ENV['CONTEXT']
$port = ENV['PORT'].to_s
$file_folder = "#{File.dirname(__FILE__)}/../../lib/resources/"
$cas = ENV['CAS']
$cas_context = $cas? ENV['CAS_CONTEXT'] : ''

require "#{File.dirname(__FILE__)}/../../lib/kuality-coeus"
require 'rspec/matchers'

World Foundry
World StringFactory
World DateFactory
World Utilities

kuality = Kuality.new ENV['BROWSER'].to_sym

# Hooks...

Before do
  @browser = kuality.browser
  @browser.cookies.clear
  # Clean out any users that might exist
  $users.clear
  $current_user=nil
  # Add the admin user to the Users...
  $users << UserObject.new(@browser)
end

After do |scenario|
  # Grab a screenshot
  if scenario.failed?
    @browser.screenshot.save 'screenshot.png'
    embed 'screenshot.png', 'image/png'
    # DEBUG
    DEBUG.message "#{Time.now}\n#{scenario.name} - Failed\non URL: #{@browser.url}"
  end
  DEBUG.message Time.now
  DEBUG.message(`ps aufxww | grep Xvfb`) if ENV['HEADLESS']
end

at_exit {
  kuality.browser.close
}