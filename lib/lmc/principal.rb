module LMC
  class Principal
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
      apply_data(response.body)
      return self
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
      @id = data['id']
      @name = data['name']
      @password = data['password']
      @type = data['type']
    end
  end
end
