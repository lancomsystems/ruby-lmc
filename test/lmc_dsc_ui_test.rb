# frozen_string_literal: true

require 'test_helper'
class LmcDSCUiTest < Minitest::Test
  @item_wrappers = [
      {'entryfield_text' => {
          'id' => '1.2.1',
          'description' => ['str.dev_name']}},

      {'entryfield_text' => {
          'id' => '1.2.2',
          'description' => ['str.dev_name', 'why.is_there_another_desc']}}
  ]

  def self.item_wrappers
    @item_wrappers
  end

  @group_wrappers = [
      {'group' => {
          'name' => ['str.dev_name'],
          'members' => @item_wrappers
      }}
  ]

  @section_wrappers = [
      {'section' => {
          'name' => ['str.foo_bar'],
          'members' => @group_wrappers
      }}
  ]

  def self.section_wrappers
    @section_wrappers
  end

  def setup
  end

  def test_dummy_item
    item = LMC::DeviceDSCUi::Item.dummy
    assert_instance_of LMC::DeviceDSCUi::Item, item
  end

  @item_wrappers.each do |item_wrapper|
    id = item_wrapper[item_wrapper.keys.first]['id']
    define_method "test_item_#{id.tr('.', '_')}" do
      item = LMC::DeviceDSCUi::Item.new item_wrapper
      assert_equal item_wrapper.keys.first, item.type
      assert_equal item_wrapper[item.type]['id'], item.id
      assert_equal item_wrapper[item.type]['description'].join(','), item.description
    end
  end

  @group_wrappers.each do |group_wrapper|
    define_method "test_group_#{group_wrapper['group']['name'].join('').tr('.', '_')}" do
      group = LMC::DeviceDSCUi::Group.new group_wrapper
      assert_equal group_wrapper['group']['members'].length, group.items.length
      assert_equal group_wrapper['group']['name'], group.names
    end
  end

  @section_wrappers.each do |section_wrapper|
    define_method "test_section_#{section_wrapper['section']['name'].join().tr('.', '_')}" do
      section_hash = section_wrapper['section']
      section = LMC::DeviceDSCUi::Section.new section_wrapper
      assert_equal section_hash['members'].length, section.groups.length
      assert_equal section_hash['name'], section.names
    end
  end

  def test_version
    version_hash = {'Version_string_thing' => self.class.section_wrappers}
    version = LMC::DeviceDSCUi::Version.new version_hash
    assert_equal version_hash.keys.first, version.version_string
    assert_equal self.class.section_wrappers.length, version.sections.length
    version.sections.each {|section| assert_instance_of LMC::DeviceDSCUi::Section, section}
    exp_items = self.class.item_wrappers.map {|im| LMC::DeviceDSCUi::Item.new im}
    assert_equal(exp_items.map(&:id), version.items.map(&:id))
  end

  def test_dscui
    mock_lmc = Minitest::Mock.new
    dsc_body_json = '
    {
    "filter": {
        "flags": [
            "VERSION"
        ],
        "sysTypeVersion": "LANCOM L-1302acn dual Wireless 10.20.0000",
        "sysHardwareWord": "00001100000000000000000000000010",
        "sysFeatureWord": "Features(list=[Feature(id=SWITCH_CONN), Feature(id=LAN_BRIDGE), Feature(id=WLAN_P2P), Feature(id=LAN_AUTHEN)], old=0x0000c010)",
        "sysRegistered": "Features(list=[Feature(id=SWITCH_CONN), Feature(id=LAN_BRIDGE), Feature(id=WLAN_P2P), Feature(id=LAN_AUTHEN)], old=0x0000c010)"
    },
    "versions": {
        "LANCOM L-1302acn dual Wireless 10.20": [
            {
                "section": {
                    "name": [
                        "str.sub_gen",
                        "str.sec_man"
                    ],
                    "section_icon": [
                        "20",
                        "1"
                    ],
                    "members": [
                        {
                            "group": {
                                "name": [
                                    "str.grp_device"
                                ],
                                "members": [
                                    {
                                        "entryfield_text": {
                                            "id": "1.2.1",
                                            "description": [
                                                "str.dev_name"
                                            ],
                                            "alias": [
                                                "ali_devname_64"
                                            ],
                                            "help_id": "1000",
                                            "max_len": "64",
                                            "no_IP": "1"
                                        }
                                    }
                                ]
                            }
},{
                            "group": {
                                "name": [
                                    "str.grp_devicefake"
                                ],
                                "members": [
                                    {
                                        "entryfield_text": {
                                            "id": "1.2.9000",
                                            "description": [
                                                "str.dev_namefake"
                                            ],
                                            "alias": [
                                                "ali_devname_64"
                                            ],
                                            "help_id": "1000",
                                            "max_len": "64",
                                            "no_IP": "1"
                                        }
                                    }
                                ]
                            }
                        }
]
}
}
]
},
    "stringtableId": "4254c42b3d2b05c89dfc02ae95965ce07b647fee",
    "stringtableLanguages": [
        "English",
        "Deutsch"
    ]
}
'
    dsc_response = Fixtures.test_response_json dsc_body_json, 200
    mock_lmc.expect :get, dsc_response, [["cloud-service-config", "configdevice", "accounts", "4996c720-11d3-43e9-9599-d63bda7272cf", "devices", "a5d83d9d-9029-4227-9a60-09f4724bb2af", "dscui"]]
    account = LMC::Account.new(mock_lmc, {'id' => '4996c720-11d3-43e9-9599-d63bda7272cf'})
    device = Fixtures.test_device account
    dscui = LMC::DeviceDSCUi.new device
    assert_mock mock_lmc
    assert_equal ['1.2.1', '1.2.9000'], dscui.item_by_id_map.keys
  end

end