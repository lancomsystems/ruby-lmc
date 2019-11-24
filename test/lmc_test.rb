# frozen_string_literal: true

require 'test_helper'
require 'credentials_helper'

class LMC::Tests::LmcTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::LMC::VERSION
  end

  def test_it_does_something_useful
    assert ::LMC.useful
  end

  def test_that_it_connects
    credentials = ::LMC::Tests::CredentialsHelper.credentials.ok
    cloud = ::LMC::Cloud.new(credentials.host, credentials.email, credentials.password)
    cloud.get_accounts
    assert true
  end

  # def test_that_it_detects_outdated_tos
  #  skip 'does not fail but creeps out the test framework'
  #  credentials = ::LMC::Tests::CredentialsHelper.credentials.outdated_tos
  #  assert_raises ::LMC::OutdatedTermsOfUseException do
  #    cloud = ::LMC::Cloud.new(credentials.host, credentials.email, credentials.password)
  #  end
  # end
end

