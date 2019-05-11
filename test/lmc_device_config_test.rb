# frozen_string_literal: true

require 'test_helper'
class LmcDeviceConfigTest < Minitest::Test
  def setup
    @account_id = '4eec92c3-3dfb-4445-800b-b9e5822e963a'
    @device_id = '8d7ff9bb-1d4c-4374-acb1-a0680ab7d85a'
    @ticket_id = '83fb175c-6c5b-4aa9-93bb-8b405e633456'
    @account = LMC::Account.new nil, 'id' => @account_id
    @device = LMC::Device.new 'id' => @device_id,
                              'account' => @account,
                              'status' => {}
    @ticket_response = OpenStruct.new body: {
        'ticketId' => @ticket_id
    }.to_json, code: 200, headers: nil
    @ticket_response.bytesize = @ticket_response.body.bytesize
    config_body = {'items' => {
        '2.4' => 'LANCOM L-1310acn dual Wireless'
    }}.to_json
    @config_response = LMC::LMCResponse.new OpenStruct.new body: config_body, code: 200, headers: nil,
                                                           bytesize: config_body.bytesize
    @config_request_args = [['cloud-service-config', 'configbuilder', 'accounts',
                             @account_id, 'devices', @device_id, 'ui']]

    @dscui_request_args = [['cloud-service-config', 'configdevice', 'accounts', '4eec92c3-3dfb-4445-800b-b9e5822e963a',
                            'devices', '8d7ff9bb-1d4c-4374-acb1-a0680ab7d85a', 'dscui']]
    @item_by_id_map = {'2.4' => LMC::DeviceDSCUi::Item.new({'some_type' => {'id' => '2.4',
                                                                            'description' => ['some.name']}})}
  end

  def test_config_direct
    mock_lmc = Minitest::Mock.new
    mock_lmc.expect :get, @config_response, @config_request_args

    config = LMC::DeviceConfig.new(mock_lmc, @account, @device)
    config.configjson
    assert_mock mock_lmc
  end

  def test_config_ticket
    mock_lmc = Minitest::Mock.new
    mock_lmc.expect :get, LMC::LMCResponse.new(@ticket_response),
                    @config_request_args
    mock_lmc.expect :get, @config_response,
                    [['cloud-service-config', 'configbuilder', 'accounts',
                      @account_id, 'devices', @device_id, 'tickets',
                      @ticket_id]]

    config = LMC::DeviceConfig.new(mock_lmc, @account, @device)
    config.configjson
    assert_mock mock_lmc
  end

  def test_config_timeout
    mock_lmc = Minitest::Mock.new
    mock_lmc.expect :get, LMC::LMCResponse.new(@ticket_response),
                    [['cloud-service-config', 'configbuilder', 'accounts',
                      @account_id, 'devices', @device_id, 'ui']]
    5.times do
      mock_lmc.expect :get, LMC::LMCResponse.new(@ticket_response),
                      [['cloud-service-config', 'configbuilder', 'accounts',
                        @account_id, 'devices', @device_id, 'tickets',
                        @ticket_id]]
    end

    config = LMC::DeviceConfig.new(mock_lmc, @account, @device)
    assert_raises Exception do
      config.configjson
    end
  end

  def test_descriptive_confighash
    mock_lmc = MiniTest::Mock.new
    mock_lmc.expect :get, @config_response, @config_request_args
    mock_dscui = MiniTest::Mock.new
    mock_dscui.expect :item_by_id_map, @item_by_id_map
    config = LMC::DeviceConfig.new mock_lmc, @account, @device
    config.stub :dscui, mock_dscui do
      dh = config.descriptive_confighash
      assert_equal dh['some.name'], @config_response.body.items['2.4']
    end
    assert_mock mock_dscui
    assert_mock mock_lmc
  end

  ##
  # This might be one of the stuipidest tests ever.
  # The method that is tested has one line.
  # This literally tests that a \.new method is called.

  def test_dscui
    mock_lmc = MiniTest::Mock.new
    mock_lmc.expect :get, @config_response, @config_request_args
    mock_account_lmc = MiniTest::Mock.new
    mock_account_lmc.expect :get, @config_response, @dscui_request_args
    config = LMC::DeviceConfig.new mock_lmc, @account, @device
    @device.stub :cloud, mock_account_lmc do
      LMC::DeviceDSCUi.stub :new, :called do
        result = config.dscui
        assert_equal :called, result
      end
    end
  end
end