# frozen_string_literal: true

require 'test_helper'
class LmcDeviceMonitorTest < Minitest::Test
  def test_device_monitor_data
    account = Fixtures.test_account
    device = Fixtures.test_device(account)
    mock_get = Minitest::Mock.new
    mock_get.expect(:call, Fixtures.test_response({}),[Array, Hash])
    LMC::Cloud.instance.stub :get, mock_get do
      r = device.record 'uptime'
      r.scalar 'datapoint', 144, 'MINUTE10'
    end

  end
end