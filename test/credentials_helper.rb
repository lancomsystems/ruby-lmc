# frozen_string_literal: true

require 'yaml'
require 'ostruct'
require 'recursive-open-struct'

module LMC::Tests::CredentialsHelper
  def self.credentials
    credentials_file = ::ENV['RUBY_LMC_TEST_CREDENTIALS_FILE']
    credentials_file ||= 'test_credentials.yaml'
    RecursiveOpenStruct.new(YAML.load_file(credentials_file))
  end
end
