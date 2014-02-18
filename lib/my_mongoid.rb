require "my_mongoid/version"

module MyMongoid
  # This module defines all the configuration options for Mongoid
  module Config
    def models
      @models ||= []
    end

    def register_model(klass)
      @models.push(klass) unless models.include?(klass)
    end
  end


  extend MyMongoid::Config


  # This is the base module for all domain objects
  module Document
    module ClassMethods
      def is_mongoid_model?
        true
      end
    end

    # Attributes
    attr_reader :attributes

    def self.included(klass)
      klass.extend(ClassMethods)
      MyMongoid.register_model(klass)
    end

    def initialize(attrs = nil)
      raise ArgumentError unless attrs.is_a?(Hash)
      @attributes = attrs
    end

    def read_attribute(name)
      @attributes[name]
    end

    def write_attribute(name, value)
      @attributes[name] = value
    end

    def new_record?
      true
    end
  end
end
