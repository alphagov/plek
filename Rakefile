require "bundler/gem_tasks"
require "rake/testtask"

task "default" => "test"

Rake::TestTask.new do |t|
  t.libs << 'test'
  t.test_files = FileList['test/**/*_test.rb']
  t.verbose = true
  t.warning = true
end

require "gem_publisher"
task :publish_gem do |t|
  gem = GemPublisher.publish_if_updated("plek.gemspec", :rubygems)
  puts "Published #{gem}" if gem
end
