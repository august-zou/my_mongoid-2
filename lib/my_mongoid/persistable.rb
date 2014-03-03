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
        doc.instance_variable_set(:@new_record, false)
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
        run_callbacks :save do
        if new_record?
          !insert.new_record?
        else
          update_document
        end
      end
    end

    def insert
      @attributes["_id"] ||= BSON::ObjectId.new
      changed_attributes = {} # reset
      doc = collection.insert(to_document)
      @new_record = doc.nil?
      self.class.instantiate(doc)
    end

    def update_attributes(attr)
      raise ArgumentError unless attr.is_a? Hash
      attr.each_pair { |k, v| send("#{k}=", v) }
      save
    end

    def delete
      selector = { "_id" => self.id }
      self.deleted = true
      self.class.collection.find(selector).remove
    end

    def deleted?
      @deleted ||= false
    end

    def update_document
      updates = atomic_updates

      unless updates.empty?
        selector = { "_id" => self.id }
        collection.find(selector).update(updates)
      end
    end

    def changed?
      !changed_attributes.empty?
    end

  end
end
