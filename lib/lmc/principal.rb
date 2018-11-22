# frozen_string_literal: true

module LMC
  class Principal
    PRINCIPAL_URL_BASE = %w[cloud-service-auth users].freeze
    attr_reader :id, :name, :password, :type

    # this is actually a bad hack because the lmc api treats users different
    # from principals.
    def self.get_self(cloud)
      new(cloud.get([PRINCIPAL_URL_BASE, 'self']))
    end

    def initialize(data)
      apply_data(data)
    end

    #returns itself, allows chaining
    def save
      response = if @id.nil?
                   Cloud.instance.post ["cloud-service-auth", "principals"], self
                 else
                   raise "editing principals not supported"
                   #@cloud.put ["cloud-service-auth", "principals", @id], self
                 end
      apply_data(response)
      return self
    end

    def to_s
      "#{@name} - #{@id}"
    end

    def to_json(*a)
      {
          "name" => @name,
          "type" => @type,
          "password" => @password
      }.to_json(*a)
    end

    private

    def apply_data(data)
      data.keys.each do |k|
        data[k.to_s] = data[k]
      end
      @id = data['id']
      @name = data['name']
      @password = data['password']
      @type = data['type']
    end
  end
end
