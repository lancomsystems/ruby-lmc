# frozen_string_literal: true
module LMC
  class ResponseException < RuntimeError
    attr_reader :response

    # Initialize a ResponseException.
    #
    # @param [Object] response restclient Response
    def initialize(response)
      if response.is_a? LMCResponse
        @response = response
      else
        @response = LMCResponse.new response
      end
    end

    def message
      cause.message
    end
  end
end

