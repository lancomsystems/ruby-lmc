require 'test_helper'
class LmcAccountDeviceTest < Minitest::Test
  def test_account_devices
    account = LMC::Account.new 'id' => '95ab6893-d75f-46d8-8235-c9e467873a49'
    mock_static_device_method = Minitest::Mock.new
    mock_static_device_method.expect :call, [], [account]
    LMC::Device.stub :get_for_account, mock_static_device_method do
      account.devices
    end
    assert mock_static_device_method.verify
  end
end