require 'active_support/core_ext'
module MyMongoid
  module Persistable
    extend ActiveSupport::Concern

    module ClassMethods
      def create(attr = {})
        model = self.new(attr)
        model.save
        model
      end
    end

    def save
      @attributes["_id"] ||= BSON::ObjectId.new
      document = collection.insert(to_document)
      @persisted = !document.nil?
    end

  end
end
