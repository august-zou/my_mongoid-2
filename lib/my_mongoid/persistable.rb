require 'active_support/core_ext'
module MyMongoid
  module Persistable
    extend ActiveSupport::Concern

    module ClassMethods
      def create(attrs = {})
        model = self.new(attrs)
        model.save
        model
      end

      def instantiate(attrs = nil)
        attributes = attrs || {}
        doc = allocate
        doc.instance_variable_set(:@attributes, attributes)
        doc.instance_variable_set(:@persisted, true)
        doc
      end

      def find(selector)
        query = selector.is_a?(Hash) ? selector : { "_id" => selector }
        result = collection.find(query).first
        raise MyMongoid::RecordNotFoundError if result.nil?
        instantiate(result)
      end

    end

    def save
      @attributes["_id"] ||= BSON::ObjectId.new
      document = collection.insert(to_document)
      @new_record = document.nil?
      !@new_record
    end

  end
end
