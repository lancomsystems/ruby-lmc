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

    def items
      response.items
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
  end
end