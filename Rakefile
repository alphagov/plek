require "bundler/gem_tasks"
require "rake/testtask"

desc "Run RuboCop"
task :lint, :environment do
  sh "bundle exec rubocop --format clang"
end

task default: %i[lint test]

Rake::TestTask.new do |t|
  t.libs << "test"
  t.test_files = FileList["test/**/*_test.rb"]
  t.verbose = true
  t.warning = true
end
