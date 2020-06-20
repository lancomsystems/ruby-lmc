# frozen_string_literal: true
module Fixtures
  def self.test_account(cloud=Fixtures.mock_lmc)
    LMC::Account.new cloud, 'id' => '8c99dceb-e7cc-4ad2-9df6-8790625e51ee', 'name' => 'Some lame test account'
  end

  def self.test_device(account = test_account(mock_lmc))
    LMC::Device.new 'id' => 'a5d83d9d-9029-4227-9a60-09f4724bb2af',
                    'account' => account, 'status' => {
            'name' => 'Fixture AP',
            'serial' => '999999999999999999999999',
            'model' => 'LANCOM L-1302acn dual Wireless',
            'hwMask' => 201326594,
            'fwLabel' => '10.20.0448 / 13.04.2019',
            'fwBuild' => '232', 'fwMinor' => 30, 'fwMajor' => 10
        }
  end

  def self.configdevice_state_response
    json = '{"a5d83d9d-9029-4227-9a60-09f4724bb2af": {
        "configState": "STORED",
        "lastConfigChange": "2019-04-14T23:13:43.863+02:00",
        "communicationState": "IDLE",
        "communicationSince": "2018-10-12T15:22:07.322+02:00",
        "updateState": "OUTDATED",
        "outdatedCause": "CHANGED",
        "currentDeviceType": "{\"type\":\"LANCOM L-1302acn dual Wireless\",\"version\":\"10.20.0448\",\"hardware\":201326594,\"features\":[4,14,15,43],\"registered\":[4,14,15,43]}",
        "conversionPending": false,
        "siteRegistrationPending": false
    }
}'
    test_response_json json
  end

  def self.test_config
    mock_lmc = Fixtures.mock_lmc [
                                     [:get, Fixtures.configdevice_state_response, [Array, Hash]]
                                 ]
    device = Fixtures.test_device Fixtures.test_account mock_lmc
    device.config
  end

  def self.test_restclient_response(body_json_string, code = 200, headers = [])
    mock = Minitest::Mock.new
    mock.expect :bytesize, body_json_string.bytesize
    mock.expect :body, body_json_string
    mock.expect :code, code
    mock.expect :headers, headers
  end

  def self.test_response_json(body_json_string, code = 200, headers = [])
    mock = test_restclient_response body_json_string, code, headers
    LMC::LMCResponse.new(mock)
  end

  def self.test_response(body, code = 200, headers = [])
    body_json_string = body.to_json
    test_response_json body_json_string, code, headers
  end
end

