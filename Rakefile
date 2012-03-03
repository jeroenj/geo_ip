require 'bundler'
Bundler::GemHelper.install_tasks

require 'rake'
require 'rspec/core/rake_task'

desc "Run all examples"
RSpec::Core::RakeTask.new(:spec) do |t|
  t.rspec_opts = %w[--color]
end

task :default => [:copy, :spec]

task :copy do
  path = File.expand_path(File.dirname(__FILE__) + '/spec')
  cp "#{path}/api.yml.example", "#{path}/api.yml" unless File.exists?("#{path}/api.yml")
end
