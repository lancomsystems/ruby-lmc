module LMC
  class OutdatedTermsOfUseException < Exception
    def initialize(response = {})
      @response = response
    end

    def response
      r = "Terms of use must be accepted before using this LMC instance:\n"
      missing.each do |tos|
        r += "Name: #{tos['name']}, Date #{tos['acceptance']}\n"

      end
      return r
    end
    def missing
      @response['details']['missing']
    end
  end


end
