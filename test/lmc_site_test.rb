# frozen_string_literal: true

require 'test_helper'
class LmcSiteTest < Minitest::Test
  def setup
    @lmc = Fixtures.mock_lmc
    @account = Fixtures.test_account @lmc
    @lmc.expect :auth_for_account, nil, [@account]
    @site_hash = { 'id' => SecureRandom.uuid, 'name' => 'foosite', 'subnetGroupId' => 1 }
  end

  def test_site_from_hash
    site = LMC::Site.new @site_hash, @account
    assert_equal @site_hash['id'], site.id
    assert_equal @site_hash['name'], site.name
    assert_equal @site_hash['subnetGroupId'], site.subnet_group_id
  end

  def test_site_from_uuid
    @lmc.expect :get, @site_hash, [Array]
    site = LMC::Site.new LMC::UUID.new(SecureRandom.uuid), @account

    @lmc.verify
    assert_equal @site_hash['id'], site.id
    assert_equal @site_hash['name'], site.name
    assert_equal @site_hash['subnetGroupId'], site.subnet_group_id
  end

  def test_site_name
    site = LMC::Site.new @site_hash, @account
    assert_equal @site_hash['name'], site.to_s
  end

  def test_configstates
    site = LMC::Site.new @site_hash, @account
    fixtures_test_response = Fixtures.test_response({})
    @lmc.expect :get, fixtures_test_response, [['cloud-service-config', 'configsubnetgroup', 'accounts', @account.id, 'subnetgroups', site.subnet_group_id, 'updatestates']]
    configstates = site.configstates
    assert_instance_of LMC::Configstates, configstates
    assert_mock @lmc
  end
end

