# frozen_string_literal: true

module LMC::JSONAble
  def self.included(klass)
    klass.class_exec do
      def to_json
        hash = {}
        self.class.resource_attributes.each do |var|
          val = instance_variable_get "@#{var}"
          hash[var] = val unless val.nil?
        end
        hash.to_json
      end
    end
  end
end
