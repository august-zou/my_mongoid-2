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

    def self.included(klass)
      klass.extend(ClassMethods)
      MyMongoid.register_model(klass)
    end
  end
end
