# frozen_string_literal: true

module LMC
  # Custom logger that hides the cloud password in restclient output
  class Logger < ::Logger
    @cloud = nil
    attr_accessor :cloud
    @@header_token_re = /"Authorization"=>"Bearer ([\S.]*)"/
    def <<(line)
      value_found = @@header_token_re.match line
      if value_found
        line.gsub! value_found[1], 'TOKEN REDACTED'
      end
      line.gsub! @cloud.password, '********'
      super
    end
  end
end

