# frozen_string_literal: true

require 'test_helper'

class LmcMembershipTest < MiniTest::Test
  def test_rm_self
    mock_lmc = MiniTest::Mock.new
    mock_lmc.expect :call, {}, [['cloud-service-auth', 'accounts', 'testid', 'members', 'self']]
    LMC::Cloud.instance.stub :delete, mock_lmc do
      a = LMC::Account.new(LMC::Cloud.instance, 'id' => 'testid')
      a.remove_membership_self
    end
    assert mock_lmc.verify
  end

  def test_membership
    membership = LMC::Membership.new
    membership.name = 'somename'
    membership.state = 'active'
    membership.type = 'mytype'
    membership.authorities = ['663d9251-4de1-4018-9c42-f902fc8080dc', '7de47837-28ea-4e5f-9502-d6e52891f61a']
    json = membership.to_json
    assert_equal '{"name":"somename","type":"mytype","state":"active","authorities":["663d9251-4de1-4018-9c42-f902fc8080dc","7de47837-28ea-4e5f-9502-d6e52891f61a"]}', json
  end
end

