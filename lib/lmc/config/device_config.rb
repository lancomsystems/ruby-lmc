# frozen_string_literal: true

module LMC
  # Represents a device config in LMC
  class DeviceConfig
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

    # def url_stringtable
    #   ['cloud-service-config', 'configdsc', 'stringtable', dscui['stringtableId']]
    # end

    def initialize(cloud, account, device)
      @cloud = cloud
      @account = account
      @device = device
      @response = nil
      @ticket_id = nil
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
      confighash.map {|k, v|
        [item_map[k].description, v]
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
            rows.each_with_index {|row, index|
              row.each_with_index {|col, col_index|
                result += "(#{key}.#{index + 1}.#{col_ids[col_index]}) = #{col}\n"}
            }
          end
        else
          result += "#{key} = #{value.class}\n"
        end
      end
      result += lcf_footer
    end

    private

    ##
    # Produces lcf header
    # TODO: Replace magic numbers, current ones are for l1302
    def lcf_header
      "(LMC Configuration of '#{@device.name}' at #{Time.now} via ruby-lmc #{LMC::VERSION})
(#{@device.status['fwLabel']}) (0x0020c11c,IDs:2,3,4,8,e,f//e08543ca,15,2b;0x0c0000d3)
[#{@device.model}] #{lcf_device_version}
[TYPE: LCF; VERSION: 1.00; HASHTYPE: none;]
"
    end

    def lcf_device_version
      v = 'v'
      v += "#{@device.status['fwMajor']}."
      v += "#{@device.status['fwMinor']}."
      v + format('%04d', @device.status['fwBuild'])
    end

    def lcf_footer
      '[END: LCF;]'
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
      attempts = 1
      until @response
        raise 'Too many attempts' if attempts > tries
        attempts += 1
        body = @cloud.get(url_ticket).body
        unless body.respond_to? :ticketId
          @ticket_id = nil
          @response = body
        end
        sleep 0.5
      end
    end

    # def stringtable
    #  @stringtable ||= @cloud.get(url_stringtable).body
    # end
  end
end
