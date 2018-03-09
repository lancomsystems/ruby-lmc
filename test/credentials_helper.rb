require 'yaml'
require 'ostruct'
require 'recursive-open-struct'

module LMC::Tests::CredentialsHelper
  def self.credentials
    credentials_file = ::ENV['RUBY_LMC_TEST_CREDENTIALS_FILE']
    RecursiveOpenStruct.new(YAML.load_file(credentials_file))
  end
end