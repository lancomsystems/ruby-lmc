module LMC
  class ResponseException < RuntimeError
    attr_reader :response

    # Initialize a ResponseException.
    #
    # @param [RestClient::ExceptionWithResponse] restclientException wrapped exception
    def initialize(restclientException = {})
      @response = LMCResponse.new restclientException.response
    end

    def message
      cause.message
    end
  end
end