require 'moped'

module MyMongoid
  # This module defines all the configuration options for Mongoid
  module Config
    def models
      @models ||= []
    end

    def register_model(klass)
      @models.push(klass) unless models.include?(klass)
    end

    def configuration
      MyMongoid::Configuration.instance
    end

    def configure(&block)
      yield(configuration)
    end

    def session(host = [], options = {})
      # TODO: add config here
      raise UnconfiguredDatabaseError if host == [] || options[:database].nil?
      @session ||= Moped::Session.new(host, :database => options[:database])
    end
  end

  extend MyMongoid::Config
end
