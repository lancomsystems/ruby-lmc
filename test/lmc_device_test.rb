require 'test_helper'
class LmcDeviceTest < Minitest::Test
  def test_getting_config
    account = LMC::Account.new 'id' => 'a24666a0-fb7d-408e-a955-29e244734912'
    device = LMC::Device.new 'id' => '33027eee-c0a1-48a5-89f5-9c99ef6c9425', 'account' => account, 'status' => {}
    mock_initializer = Minitest::Mock.new
    mock_initializer.expect :call, Object.new, [LMC::Cloud, account, device]
    LMC::DeviceConfig.stub :new, mock_initializer do
      device.config
    end
    assert_mock mock_initializer
  end
end