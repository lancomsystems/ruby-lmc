# frozen_string_literal: true

require 'credentials_helper'
module LMC::Tests
  class CloudInstanceHelper
    ok_credentials = LMC::Tests::CredentialsHelper.credentials.ok
    LMC::Cloud.cloud_host = ok_credentials.host
    LMC::Cloud.user = ok_credentials.email
    LMC::Cloud.password = ok_credentials.password
    # LMC::Cloud.debug = true

    # def self.using_credentials credentials_name
    #  credentials = LMC::Tests::CredentialsHelper.credentials.ok
    #  cloud = ::LMC::Cloud.new(credentials.host, credentials.email, credentials.password)
    #  return cloud
    # end
  end
end

