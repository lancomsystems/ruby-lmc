# frozen_string_literal: true

# frozen_string_literal

require 'test_helper'
class LmcDeviceConfigLCFTest < Minitest::Test
  def test_integration
    items = JSON.parse '{
        "1.2.1": "l-1302",
        "1.2.9.27": {
            "colIds": [
                "8",
                "1",
                "3"
            ],
            "rows": [
                [
                    "1",
                    "public",
                    "public"
                ]
            ]
        }
    }'

    expected_lcf = "(LMC Configuration of 'Fixture AP' at 1970-01-01 01:00:00 +0100 via ruby-lmc #{LMC::VERSION})
() (0x0020c11c,IDs:2,3,4,8,e,f//e08543ca,15,2b;0x0c0000d3)
[] v10.30.0232
[TYPE: LCF; VERSION: 1.00; HASHTYPE: none;]
1.2.1 = l-1302
<1.2.9.27>
(1.2.9.27.1.8) = 1
(1.2.9.27.1.1) = public
(1.2.9.27.1.3) = public
[END: LCF;]
"

    device = Fixtures.test_device
    config = device.config
    config.stub :items, items do
      Time.stub :now, Time.at(0) do
        assert_equal expected_lcf, config.lcf
      end
    end

  end
end
