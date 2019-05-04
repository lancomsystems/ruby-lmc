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

MiniTest::Reporters.use!

module Fixtures
  def self.test_account
    LMC::Account.new 'id' => '8c99dceb-e7cc-4ad2-9df6-8790625e51ee'
  end

  def self.test_device(account)
    LMC::Device.new 'id' => 'a5d83d9d-9029-4227-9a60-09f4724bb2af',
                    'account' => account, 'status' => {}
  end

  def self.test_response(body, code = 200, headers = [])
    body_json_string = body.to_json
    mock = Minitest::Mock.new
    mock.expect :bytesize, body_json_string.bytesize
    mock.expect :body, body_json_string
    mock.expect :code, code
    mock.expect :headers, headers
    LMC::LMCResponse.new(mock)
  end
end
