require 'simplecov' # These two lines must go first
#only check coverage if not running a specific test
if ARGV.grep(/_test\.rb/).count > 1
  SimpleCov.start do
    refuse_coverage_drop
  end
end
$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)

require "lmc"
module LMC::Tests
end
require 'cloud_instance_helper'


require "minitest/autorun"
require 'minitest/reporters'

MiniTest::Reporters.use!
