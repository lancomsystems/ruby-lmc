require 'ostruct'
module LMC
  class LMCResponse

    attr_reader :body, :code, :headers

    def initialize(response)
      @body_object = {}
      if response.bytesize > 0
        @body_object = JSON.parse response.body
      end
      if @body_object.class == Array
        @body = @body_object.map {|elem|
          if elem.is_a? Hash then
            OpenStruct.new(elem)
          else
            elem
          end}
      elsif @body_object.class == Hash
        @body = OpenStruct.new(@body_object)
      elsif @body_object.class == TrueClass || @body_object.class == FalseClass
        @body = @body_object
      else
        raise "Unknown json parse result"
      end
      @code = response.code
      @headers = response.headers
    end

    # body_object and these methods allow to use LMCResponse objects in place
    # of the old response which was just the body parsed to a hash or array
    def [](key)
      @body_object[key]
    end

    def []=(key, val)
      @body_object[key] = val
    end

    def keys
      @body_object.keys
    end

    def map(&block)
      @body_object.map(&block)
    end

    def each(&block)
      @body_object.each(&block)
    end

    def to_s
      "Response: Code: #{@code}, Body: #{@body_object.to_s}"
    end

    def empty?
        @body_object.empty?
    end
  end

end
