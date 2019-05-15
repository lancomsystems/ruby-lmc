# frozen_string_literal: true

require 'test_helper'
class LmcDeviceMonitorTest < Minitest::Test
  def test_device_monitor_data
    mock_lmc = Fixtures.mock_lmc
    mock_lmc.expect :get, Fixtures.test_response({}), [Array, Hash]
    mock_lmc.expect :get, Fixtures.test_response({}), [Array, Hash]
    account = Fixtures.test_account mock_lmc
    device = Fixtures.test_device(account)
    r = device.record 'uptime'
    r.scalar 'datapoint', 144, 'MINUTE10'
    r.row 'dunno', 12, 'DAY'
    assert_mock mock_lmc

  end
end
