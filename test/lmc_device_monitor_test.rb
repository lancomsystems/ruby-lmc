# frozen_string_literal: true

require 'test_helper'

class LmcDeviceMonitorTest < Minitest::Test
  def setup
    @account = LMC::Account.new Fixtures.mock_lmc, 'id' => @account_id
    @device = LMC::Device.new 'id' => @device_id,
                              'account' => @account,
                              'status' => {}
  end

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

  def test_device_monitor_widgets
    @device.cloud.expect :get, Fixtures.test_response({}), [Array, {:widgetItemIds=>"df63db22-511a-4a10-a156-12ab0ace989d,6e2bb555-2b0d-4081-be6d-5b1608b06b49"}]
    widgets = @device.get_monitor_widgets ['df63db22-511a-4a10-a156-12ab0ace989d', '6e2bb555-2b0d-4081-be6d-5b1608b06b49']
    assert_mock @device.cloud
  end
end

