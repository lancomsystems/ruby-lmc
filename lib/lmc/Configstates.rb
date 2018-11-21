# frozen_string_literal: true

module LMC
  class Configstates
    attr_reader :actual, :outdated

    def initialize(data)
      @actual = data["ACTUAL"]
      @outdated = data["OUTDATED"]
      @actual ||= 0
      @outdated ||= 0
    end

  end

end