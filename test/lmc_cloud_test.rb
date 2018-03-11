require 'test_helper'

class LmcCloudTest < Minitest::Test

  def test_that_it_can_get_account_objects
    cloud = LMC::Cloud.instance
    accounts = cloud.get_accounts_objects
    refute_empty accounts
    assert_instance_of LMC::Account, accounts.first
  end

  def test_backstage_infos
    cloud = LMC::Cloud.instance
    infos = cloud.get_backstage_serviceinfos
  end

  def test_password_hidden
    cloud = LMC::Cloud.instance
    infos = cloud.inspect
    refute_match /password/, infos
  end

end
