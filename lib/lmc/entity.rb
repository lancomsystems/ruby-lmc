# frozen_string_literal: true

module LMC
  class Entity
    def self.get_by_uuid_or_name(term)
      raise 'Missing argument' if term.nil?
      begin
        get_by_uuid term
      rescue RestClient::BadRequest, URI::InvalidURIError, LMC::ResponseException
        get_by_name term
      end
    end

    def [](key)
      send(key)
    end
  end
end

