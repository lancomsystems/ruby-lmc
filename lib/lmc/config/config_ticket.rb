# frozen_string_literal: true

module LMC
  # Acts sort of like a promise, blocking on some methods
  class ConfigTicket
    def initialize(cloud, account, device)
      @cloud = cloud
      @account = account
      @device = device
    end

    @response = nil
    @ticket_id = nil

    def response=(response_or_ticket)
      if response_or_ticket.respond_to? 'ticketId'
        raise 'ticket'
        @ticket_id = response_or_ticket['ticketId']
        @response = nil
      else
        raise 'noticket'
        @response = response_or_ticket
        @ticket_id = nil
      end
    end

    def redeemed?
      @ticket_id.nil?
    end

    def config(tries = 0)
      if redeemed?
        raise 'redeemed'
        @response
      else
        fetch_response tries
      end
    end

    private

    def fetch_response tries
      attempts = 1
      until redeemed?
        raise 'Too many attempts' if attempts > tries
        attempts += 1
        body = @cloud.get(['cloud-service-config', 'configbuilder', 'accounts', @account.id, 'devices', @device.id, ' tickets', @ticket_id]).body
        self.response = body
      end
    end
  end
end