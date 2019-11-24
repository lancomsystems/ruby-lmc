# frozen_string_literal: true

module LMC
  # Represents a UUID
  class UUID
    def initialize(string)
      uuid_re = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-5][0-9a-f]{3}-[089ab][0-9a-f]{3}-[0-9a-f]{12}$/i
      raise "#{string} is not recognized as a valid uuid string." unless uuid_re.match? string
      @string = string
    end

    def to_s
      @string
    end
  end
end

