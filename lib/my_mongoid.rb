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

      # Fields
      def field(name, options = {})
        named = name.to_s

        define_method(named) { @attributes[named] }

        define_method(named + '=') do |value|
          @attributes[named] = value
        end

        # add field to class variable @fields
        add_field(named)
      end


      def fields
        @fields ||= {}
      end

      def add_field(name, options = {})
        @fields ||= {}
        raise DuplicateFieldError if @fields.include?(name)
        @fields[name] = MyMongoid::Field.new(name)
      end
    end


    # extend the mixed class's class method
    def self.included(klass)
      klass.extend(ClassMethods)
      klass.field(:_id)
      MyMongoid.register_model(klass)
    end


    # Attributes
    attr_reader :attributes

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


  class Field
    attr_accessor :name

    def initialize(name)
      @name = name
    end
  end


  class DuplicateFieldError < RuntimeError
  end
end
