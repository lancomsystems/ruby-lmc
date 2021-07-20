# frozen_string_literal: true

module LMC
  class OutdatedTermsOfUseException < ResponseException

    def response
      r = "Terms of use must be accepted before using this LMC instance:\n"
      missing.each do |tos|
        r += "Name: #{tos['name']}, Date #{tos['acceptance']}\n"

      end
      r
    end

    def missing
      @response['details']['missing']
    end
  end
end

