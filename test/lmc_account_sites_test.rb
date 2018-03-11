require 'test_helper'
class LmcAccountSitesTest < Minitest::Test
  ACCOUNT_NAME = 'ruby-lmc'

  def test_account_without_sites
    account = LMC::Account.get_by_name ACCOUNT_NAME
    sites = account.sites
    refute_nil sites
    assert_empty sites
  end
end