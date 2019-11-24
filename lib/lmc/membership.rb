# frozen_string_literal: true

module LMC
  class Membership
    attr_accessor :name, :type, :state, :authorities

    def to_json(*a)
      {
          'name' => @name,
          'type' => @type,
          'state' => @state,
          'authorities' => @authorities
      }.to_json(*a)
    end
  end
end

