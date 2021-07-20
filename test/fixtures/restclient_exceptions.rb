# frozen_string_literal: true

module Fixtures
  def self.restclient_exception(bodystring, http_status_code = '200')
    # dummy objects to satisfy RestClient::Response
    http_response = Net::HTTPResponse.new('', http_status_code, '')
    rest_client_request = RestClient::Request.new({ :method => :post, url: 'http://localhost/' })
    e = ::RestClient::ExceptionWithResponse.new
    e.response = RestClient::Response.create bodystring, http_response , rest_client_request
    e
  end
end

