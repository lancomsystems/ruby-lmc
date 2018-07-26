module LMC
  class Authority
    attr_accessor :account, :id, :name, :visibility, :type

    def initialize(data, account)
      @cloud = Cloud.instance
      apply_data(data)
      @account = account
    end

    def rights
      # GET /accounts/{accountId}/authorities/{authorityId}/rights
      @cloud.auth_for_account @account
      response = @cloud.get ['cloud-service-auth', 'accounts', @account.id, 'authorities', @id, 'rights']
      return response.body.to_s
    end

    #returns itself, allows chaining
    def save
      response = if @id.nil?
                   Cloud.instance.post ["cloud-service-auth", 'accounts', @account.id, "authorities"], self
                 else
                   raise "editing authorities not supported"
                   #@cloud.put ["cloud-service-auth", "principals", @id], self
                 end
      apply_data(response.body)
      return self
    end

    def to_json(*a)
      {
          "name" => @name,
          "type" => @type,
          "visibility" => @visibility
      }.to_json(*a)
    end

    def to_s
      "#{@name} (#{@type}/#{@visibility})"
    end

    private

    def apply_data(data)
      @id = data['id']
      @name = data['name']
      @visibility = data['visibility']
      @type = data['type']
    end
  end
end
