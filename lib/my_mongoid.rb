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
        @attributes ||= {}

        define_method(named) { @attributes[named] }

        define_method(named + '=') do |value|
          @attributes[named] = value
        end

        # add field to class variable @fields
        add_field(named, options)
      end

      def fields
        @fields ||= {}
      end

      def add_field(name, options = {})
        @fields ||= {}
        raise DuplicateFieldError if @fields.include?(name)
        @fields[name] = MyMongoid::Field.new(name, options)
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
      @attributes = {}
      process_attributes(attrs)
    end

    def method_missing(meth,*args, &block)
      if meth.to_s =~ /.*=/
          raise UnknownAttributeError
      end
    end

    def process_attributes(attrs = nil)
      attrs ||= {}
      if !attrs.empty?
        attrs.each_pair do |name, value|
          send("#{name}=", value)
        end
      end
    end

    alias :attributes= :process_attributes

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
    attr_accessor :name, :options

    def initialize(name, options)
      @name = name
      @options = options
    end
  end


  class DuplicateFieldError < RuntimeError
  end


  class UnknownAttributeError < RuntimeError
  end
end
