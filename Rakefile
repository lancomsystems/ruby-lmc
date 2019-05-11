# frozen_string_literal: true

require 'bundler/gem_tasks'
require 'rake/testtask'
require 'rubocop/rake_task'
require 'rdoc/task'

Rake::TestTask.new(:test) do |t|
  t.libs << 'test'
  t.libs << 'lib'
  t.test_files = FileList['test/**/*_test.rb']
end


RuboCop::RakeTask.new(:autocop) do |t|
  t.options = ['--only', 'Style/FrozenStringLiteralComment,Style/StringLiterals', '--auto-correct', 'lib', 'test', 'Rakefile', 'lmc.gemspec']
end
task :default => :test


RDoc::Task.new do |rdoc|
  rdoc.main = 'README.rdoc'
  rdoc.rdoc_files.include('README.rdoc', 'lib/**/*.rb')
end