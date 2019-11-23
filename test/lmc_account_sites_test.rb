# frozen_string_literal: true

require 'test_helper'
class LmcAccountSitesTest < Minitest::Test
  ACCOUNT_NAME = 'ruby-lmc'

  def test_account_without_sites
    account = LMC::Account.get_by_name ACCOUNT_NAME
    sites = account.sites
    refute_nil sites
    assert_empty sites
  end

  def test_account_with_sites
    lmc = Fixtures.mock_lmc
    lmc.expect :auth_for_accounts, nil, [Object]
    site_hash = { 'id' => '179be8ed-b522-44d5-ad5f-b03f25ce08d9', 'name' => 'testsite',
                                   'subnetGroupId' => '0b27261c-227d-4e28-8b87-35b5594ea278' }
    lmc.expect :get, Fixtures.test_response(['179be8ed-b522-44d5-ad5f-b03f25ce08d9']), [Array, Object]
    lmc.expect :auth_for_account, nil, [Object]
    lmc.expect :get, Fixtures.test_response(site_hash), [Array]
      account = LMC::Account.new lmc, 'id' => 'e8ab2250-8d79-442b-a13c-4144e0237b3e'
      sites = account.sites
      refute_empty sites
  end
end
