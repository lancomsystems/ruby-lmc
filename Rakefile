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
      'Gemspec/OrderedDependencies',
      'Layout/EmptyLineBetweenDefs',
      'Layout/EmptyLines',
      'Layout/EmptyLinesAroundClassBody',
      'Layout/EmptyLinesAroundMethodBody',
      'Layout/EmptyLinesAroundModuleBody',
      'Layout/LeadingCommentSpace',
      'Layout/SpaceAfterComma',
      'Layout/SpaceAroundOperators',
      'Layout/SpaceInsideBlockBraces',
      'Layout/SpaceInsideHashLiteralBraces',
      'Layout/TrailingEmptyLines',
      'Lint/RedundantStringCoercion',
      'Lint/UnusedBlockArgument',
      'Style/CommentAnnotation',
      'Style/FrozenStringLiteralComment',
      'Style/MethodDefParentheses',
      'Style/RedundantReturn',
      'Style/RedundantSelf',
      'Style/StabbyLambdaParentheses',
      'Style/StringLiterals',
      'Style/StringLiteralsInInterpolation'
  ]
  t.options = ['--only', autofix.join(','), '--auto-correct', 'lib', 'test', 'Rakefile', 'lmc.gemspec']
end
task :default => :test

RDoc::Task.new do |rdoc|
  rdoc.main = 'README.rdoc'
  rdoc.rdoc_files.include('README.rdoc', 'lib/**/*.rb')
end

