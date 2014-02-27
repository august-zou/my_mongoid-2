require 'my_mongoid/config'
require 'my_mongoid/errors'
require 'my_mongoid/persistable'

module MyMongoid
  # This is the base module for all domain objects
  module Document
    extend ActiveSupport::Concern

    include Persistable

    attr_reader :attributes
    attr_accessor :new_record # state

    module ClassMethods
      def is_mongoid_model?
        true
      end

      # Fields
      def field(name, options = {})
        named = name.to_s
        aliaed = options[:as]

        add_field(named, options) # add field to class variable @fields

        create_accessors(named, named, options)
        create_accessors(named, aliaed, options) if aliaed
      end

      def fields
        @fields ||= {}
      end

      def add_field(name, options = {})
        @fields ||= {}
        raise DuplicateFieldError if @fields.include?(name)
        @fields[name] = MyMongoid::Field.new(name, options)
      end

      def create_accessors(name, meth, options={})
        meth = meth.to_s
        name = name.to_s

        define_method(meth) { @attributes[name] }

        define_method(meth + '=') do |value|
          @attributes[name] = value
        end
      end

      # Collection name
      def collection_name
        name.tableize
      end

      def collection
        MyMongoid.session[collection_name]
      end

    end

    # extend the mixed class's class method
    def self.included(klass)
      klass.extend(ClassMethods)
      klass.field(:_id)
      klass.create_accessors(:_id, :id)
      MyMongoid.register_model(klass)
    end

    def initialize(attrs = nil)
      raise ArgumentError unless attrs.is_a?(Hash)
      @attributes = {}
      @new_record = true
      process_attributes(attrs) do
        yield self if block_given?
      end
      defaults = self.class.fields.inject({}) do |c, (k, v)|
        c[k] = v.default_val; c
      end
      @attributes = defaults.merge(@attributes)
    end

    def method_missing(meth, *args, &block)
      raise UnknownAttributeError if meth.to_s =~ /.*=/
      super
    end

    def process_attributes(attrs = nil)
      attrs ||= {}
      unless attrs.empty?
        attrs.each_pair do |name, value|
          send("#{name}=", value)
        end
      end
      yield self if block_given?
    end

    alias :attributes= :process_attributes

    def read_attribute(name)
      @attributes[name]
    end

    def write_attribute(name, value)
      @attributes[name] = value
    end

    def new_record?
      @new_record
    end

    def to_document
      @attributes
    end

    def collection
      self.class.collection
    end
  end

  class Field
    attr_accessor :name, :options, :default_val

    def initialize(name, options = {})
      @name = name
      @options = options
      @default_val = options[:default]
    end
  end
end
