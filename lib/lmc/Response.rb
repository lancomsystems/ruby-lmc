# frozen_string_literal: true

require 'ostruct'
require 'recursive-open-struct'
module LMC
  class LMCResponse
    attr_reader :body, :code, :headers

    def initialize(response)
      @body_object = {}
      if response.bytesize > 0
        @body_object = JSON.parse response.body
      end
      if @body_object.class == Array
        @body = @body_object.map { |elem|
          if elem.is_a? Hash then
            RecursiveOpenStruct.new(elem, recurse_over_arrays: true)
          else
            elem
          end}
      elsif @body_object.class == Hash
        @body = RecursiveOpenStruct.new(@body_object, recurse_over_arrays: true)
      elsif @body_object.class == TrueClass || @body_object.class == FalseClass
        @body = @body_object
      else
        raise "Unknown json parse result: #{@body_object.class}"
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
      "Response: Code: #{@code}, Body: #{@body_object}"
    end

    def empty?
        @body_object.empty?
    end
  end
end

