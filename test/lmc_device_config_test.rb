# frozen_string_literal: true

require 'test_helper'
class LmcDeviceConfigTest < Minitest::Test
  def setup
    @account_id = '4eec92c3-3dfb-4445-800b-b9e5822e963a'
    @device_id = '8d7ff9bb-1d4c-4374-acb1-a0680ab7d85a'
    @ticket_id = '83fb175c-6c5b-4aa9-93bb-8b405e633456'
    @account = LMC::Account.new 'id' => @account_id
    @device = LMC::Device.new 'id' => @device_id,
                              'account' => @account,
                              'status' => {}
    @ticket_response = OpenStruct.new body: {
        'ticketId' => @ticket_id
    }.to_json, code: 200, headers: nil
    @ticket_response.bytesize = @ticket_response.body.bytesize
    config_body = { 'items' => {
        '2.4' => 'LANCOM L-1310acn dual Wireless'
    } }.to_json
    @config_response = OpenStruct.new body: config_body, code: 200, headers: nil
    @config_response.bytesize = @config_response.body.bytesize
  end

  def test_config_direct
    mock_lmc = Minitest::Mock.new
    mock_lmc.expect :get, LMC::LMCResponse.new(@config_response),
                    [['cloud-service-config', 'configbuilder', 'accounts',
                      @account_id, 'devices', @device_id, 'ui']]

    config = LMC::DeviceConfig.new(mock_lmc, @account, @device)
    config.configjson
    assert_mock mock_lmc
  end
  def test_config_ticket
    mock_lmc = Minitest::Mock.new
    mock_lmc.expect :get, LMC::LMCResponse.new(@ticket_response),
                    [['cloud-service-config', 'configbuilder', 'accounts',
                      @account_id, 'devices', @device_id, 'ui']]
    mock_lmc.expect :get, LMC::LMCResponse.new(@config_response),
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
end