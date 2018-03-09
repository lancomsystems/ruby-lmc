require "test_helper"
require 'credentials_helper'

::LMC::Cloud.debug = true

class LmcTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::LMC::VERSION
  end

  def test_it_does_something_useful
    assert ::LMC.useful
  end

  def test_that_it_connects
    credentials = ::LMC::Tests::CredentialsHelper.credentials.ok
    cloud = ::LMC::Cloud.new(credentials.host, credentials.email, credentials.password)
    accounts = cloud.get_accounts
    puts accounts.inspect
    assert true
  end

  def test_that_it_detects_outdated_tos
    credentials = ::LMC::Tests::CredentialsHelper.credentials.outdated_tos
    assert_raises ::LMC::OutdatedTermsOfUseException do
      cloud = ::LMC::Cloud.new(credentials.host, credentials.email, credentials.password)
      accounts = cloud.get_accounts
    end
  end
end
