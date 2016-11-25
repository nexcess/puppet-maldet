require 'puppetlabs_spec_helper/rake_tasks'
require 'puppet-lint/tasks/puppet-lint'

PuppetLint.configuration.send('disable_140chars')
PuppetLint.configuration.send('disable_documentation')

exclude_paths = %w(
  pkg/**/*
  vendor/**/*
  .vendor/**/*
  spec/**/*
)
PuppetLint.configuration.ignore_paths = exclude_paths

# These gems aren't always present, for instance
# on Travis with --without development
begin
  require 'puppet_blacksmith/rake_tasks'
rescue LoadError # rubocop:disable Lint/HandleExceptions
end


desc "Run acceptance tests"
RSpec::Core::RakeTask.new(:acceptance) do |t|
  t.pattern = 'spec/acceptance'
end
