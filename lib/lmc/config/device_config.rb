# frozen_string_literal: true

module LMC
  # Represents a device config in LMC
  class DeviceConfig
    attr_reader :state

    def url_configbuilder
      ['cloud-service-config', 'configbuilder', 'accounts',
       @account.id, 'devices', @device.id, 'ui']
    end

    def url_ticket
      ['cloud-service-config',
       'configbuilder',
       'accounts',
       @account.id,
       'devices',
       @device.id,
       'tickets',
       @ticket_id]
    end

    def url_state
      %W(cloud-service-config configdevice accounts #{@account.id} state)
    end

    # def url_stringtable
    #   ['cloud-service-config', 'configdsc', 'stringtable', dscui['stringtableId']]
    # end

    def initialize(cloud, account, device)
      @cloud = cloud
      @account = account
      @device = device
      @response = nil
      @ticket_id = nil
      # state returns an object with each requested device id pointing to a state object.
      @state = @cloud.get(url_state, deviceIds: @device.id.to_s).body[@device.id]
    end

    def configjson
      confighash.to_json
    end

    def confighash
      items.to_h
    end

    ##
    # Returns a hash similar to #confighash but with the OIDs replaced with more
    # meaningful descriptions.

    def descriptive_confighash
      item_map = dscui.item_by_id_map
      confighash.map { |k, v|
        [item_map[k.to_s].description, v]
      }.to_h
    end

    def items
      response.items
    end

    def dscui
      @dscui ||= DeviceDSCUi.new @device
    end

    def lcf
      # lfc format findings:
      # group headings in {} do not matter
      # indentation does not matter
      # table oids need to be enclosed in <>
      # table cell oids need to be enclosed in () and should follow table oids

      result = ''
      result += lcf_header
      items.each do |key, value|
        if value.instance_of? String
          result += "#{key} = #{value}\n"
        elsif value.instance_of? Hash
          rows = value['rows']
          col_ids = value['colIds']
          if rows.length > 0
            result += "<#{key}>\n"
            rows.each_with_index { |row, index|
              row.each_with_index { |col, col_index|
                result += "(#{key}.#{index + 1}.#{col_ids[col_index]}) = #{col}\n"}
            }
          end
        else
          raise 'Unexpected value in config items: ' + value.class.to_s
        end
      end
      result += lcf_footer
    end

    def current_device_type
      OpenStruct.new JSON.parse state['currentDeviceType']
    end

    ##
    # @return [String]
    def feature_mask_lower32_hex
      feature_mask = 0
      lower_features = current_device_type.features.select { |feature| feature < 32 }
      lower_features.each do |feature_pos|
        feature = 2**feature_pos
        feature_mask = feature_mask | feature
      end
      if feature_mask == 0
        '0x00000000'
      else
        format '%#010x', feature_mask
      end
    end

    def lcf_device_version
      v = 'v'
      v += "#{@device.status['fwMajor']}."
      v += "#{@device.status['fwMinor']}."
      v + format('%04d', @device.status['fwBuild'])
    end

    ##
    # Gives the feature IDs as a string like this: "IDs:2,3,f"
    # @return [String]
    def lcf_feature_id_string
      hex_features = current_device_type.features.map { |feature| feature.to_s 16 }
      "IDs:#{hex_features.join(',')}"
    end

    private

    ##
    # Produces lcf header
    # @return [String]
    def lcf_header
      "(LMC Configuration of '#{@device.name}' at #{Time.now} via ruby-lmc #{LMC::VERSION})
(#{@device.status['fwLabel']}) (#{lcf_feature_hw_string})
[#{@device.model}] #{lcf_device_version}
[TYPE: LCF; VERSION: 1.00; HASHTYPE: none;]
"
    end

    ##
    # Gives the feature mask, the feature IDs and the hardware mask as string for the lcf
    # header like this: "0x0000c010,IDs:4,e,f//e0901447,2b;0x0c000002"
    # @return [String]
    def lcf_feature_hw_string
      "#{feature_mask_lower32_hex},#{lcf_feature_id_string};#{@device.hwmask_hex}"
    end

    def lcf_footer
      "[END: LCF;]\n"
    end

    def response
      return @response unless @response.nil?
      fetch_result
    end

    def fetch_result
      response_or_ticket = @cloud.get(url_configbuilder).body
      if response_or_ticket.respond_to? 'ticketId'
        @ticket_id = response_or_ticket.ticketId
        redeem_ticket 5
      else
        @response = response_or_ticket
      end
      @response
    end

    def redeem_ticket(tries)
      wait_seconds = 0.5
      attempts = 1
      until @response
        raise "Timeout waiting for config (#{attempts * wait_seconds}s)" if attempts > tries
        attempts += 1
        body = @cloud.get(url_ticket).body
        unless body.respond_to? :ticketId
          @ticket_id = nil
          @response = body
        end
        sleep wait_seconds * attempts
      end
    end

    # def stringtable
    #  @stringtable ||= @cloud.get(url_stringtable).body
    # end
  end
end

