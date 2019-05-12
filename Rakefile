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
  autofix = [
      'Layout/EmptyLines',
      'Layout/EmptyLinesAroundClassBody',
      'Layout/EmptyLinesAroundModuleBody',
      'Layout/EmptyLineBetweenDefs',
      'Layout/LeadingCommentSpace',
      'Layout/SpaceAroundOperators',
      'Layout/SpaceInsideBlockBraces',
      'Layout/SpaceInsideHashLiteralBraces',
      'Layout/TrailingBlankLines',
      'Style/BracesAroundHashParameters',
      'Style/CommentAnnotation',
      'Style/FrozenStringLiteralComment',
      'Style/MethodDefParentheses',
      'Style/RedundantSelf',
      'Style/RedundantReturn',
      'Style/StringLiterals',
      'Style/StringLiteralsInInterpolation']
  t.options = ['--only', autofix.join(','), '--auto-correct', 'lib', 'test', 'Rakefile', 'lmc.gemspec']
end
task :default => :test

RDoc::Task.new do |rdoc|
  rdoc.main = 'README.rdoc'
  rdoc.rdoc_files.include('README.rdoc', 'lib/**/*.rb')
end
