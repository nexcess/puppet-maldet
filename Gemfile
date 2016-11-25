source 'https://rubygems.org'

group :tests do
  gem 'puppetlabs_spec_helper'
  gem 'puppet-lint', '~>2.0'
  gem 'puppet-lint-unquoted_string-check'
  gem 'puppet-lint-empty_string-check'
  gem 'puppet-lint-leading_zero-check'
  gem 'puppet-lint-variable_contains_upcase'
  gem 'puppet-lint-version_comparison-check'
  gem 'rspec'
  gem 'rspec-puppet'
  gem 'rspec-puppet-facts'
  gem 'metadata-json-lint'
end

# json_pure 2.0.2 added a requirement on ruby >= 2. We pin to json_pure 2.0.1
# if using ruby 1.x for puppet 3.2 through puppet 3.4
gem 'json_pure', '<=2.0.1', :require => false if RUBY_VERSION =~ /^1\./

group :development do
  gem "puppet-blacksmith"
end

group :system_tests do
  gem "beaker"
  gem "beaker-rspec"
  gem "beaker-puppet_install_helper"
end

if facterversion = ENV['FACTER_GEM_VERSION']
  gem 'facter', facterversion, :require => false
else
  gem 'facter', :require => false
end

if puppetversion = ENV['PUPPET_GEM_VERSION']
  gem 'puppet', puppetversion, :require => false
else
  gem 'puppet', :require => false
end
