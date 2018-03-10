require 'test_helper'
require 'cloud_instance_helper'


class LMC::Tests::LmcCloudTest < Minitest::Test

  def test_that_it_can_get_account_objects
    cloud = LMC::Cloud.instance
    accounts = cloud.get_accounts_objects
    refute_empty accounts
    assert_instance_of LMC::LMCAccount, accounts.first
  end

end
