require "bundler/gem_tasks"
require "rake/testtask"
require "rubocop/rake_task"

RuboCop::RakeTask.new

task default: %i[rubocop test]

Rake::TestTask.new do |t|
  t.libs << "test"
  t.test_files = FileList["test/**/*_test.rb"]
  t.verbose = true
  t.warning = true
end
