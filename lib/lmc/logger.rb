# frozen_string_literal: true

module LMC
  # Custom logger that hides the cloud password in restclient output
  class Logger < ::Logger
    @cloud = nil
    attr_accessor :cloud
    def <<(line)
      super line.gsub @cloud.password, '********'
    end
  end
end
