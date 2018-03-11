$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)

require "lmc"
module LMC::Tests
end
require 'cloud_instance_helper'

require 'simplecov' # These two lines must go first
SimpleCov.start

require "minitest/autorun"
require 'minitest/reporters'

MiniTest::Reporters.use!
