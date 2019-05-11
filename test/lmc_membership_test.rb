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
end
