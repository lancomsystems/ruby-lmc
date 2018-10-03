# frozen_string_literal: true

module LMC
  class Logger < ::Logger
    def initialize(dest, cloud)
      @cloud = cloud
      super dest
    end
    def << line
      super line.gsub @cloud.password, '********'
    end
  end
end