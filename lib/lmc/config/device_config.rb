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


    private

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

    #def stringtable
    #  @stringtable ||= @cloud.get(url_stringtable).body
    #end
  end
end