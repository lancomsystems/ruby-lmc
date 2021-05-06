# frozen_string_literal: true

require 'simplecov' # These two lines must go first
# only check coverage if not running a specific test
# with 'rake test' all the files are passed in argv
# - if more than one test is in, we assume it's all
# with minitest runner in RubyMine, ARGV is empty when running all tests.
if ARGV.grep(/_test\.rb/).count > 1 || ARGV.empty?
  SimpleCov.start do
    refuse_coverage_drop
    add_filter '/test/'
  end
end
$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'securerandom'

require 'lmc'
module LMC
  module Tests
  end
end
require 'cloud_instance_helper'

require 'minitest/autorun'
require 'minitest/reporters'

# Removing minitest to be compatible with IntelliJ Minitest
unless ENV['RM_INFO']
  MiniTest::Reporters.use!
end

Dir.glob(File.expand_path('../fixtures/*.rb', __FILE__)).each do |file|
  require file
end

