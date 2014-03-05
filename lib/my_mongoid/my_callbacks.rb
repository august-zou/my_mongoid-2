require 'active_support/core_ext'
require "active_model/callbacks"

module MyMongoid
  module MyCallbacks
    extend ActiveSupport::Concern

    module ClassMethods
      def define_callbacks(name,opts={})
        class_attribute "_#{name}_callbacks"
        set_callbacks name, CallbackChain.new
      end

      def set_callbacks(name, callbacks)
        send "_#{name}_callbacks=", callbacks
      end

      def set_callback(name,kind,filter)
        cbn = send "_#{name}_callbacks"
        cb = Callback.new(kind,filter)
        cbn.append cb
      end
    end

    def run_callbacks(name,&main)
      cbn = self.class.send "_#{name}_callbacks"
      cbn.invoke(self,main)
    end

    class CallbackChain 
      attr_accessor :chain

      def initialize()
        @empty = true
        @chain = []
      end

      def empty?
        @empty
      end

      def append(cb)
        @chain << cb
      end

      def invoke(target,&main)
        # sort the callbacks in @chain into different kinds
        before_callbacks, around_callbacks, after_callbacks = sort_callbacks @chain

        before_callbacks.each do |cb|
          cb.invoke(target)
        end

        # how do we implement the around callbacks?
        main.call

        after_callbacks.each do |cb|
          cb.invoke(target)
        end
      end

      def _invoke(i,target,&block)
        if i==0 return
          block.call
          _invoke(i-1,target,block)

      end

      def sort_callbacks(chain)
        @before_callbacks = [] 
        @around_ballbacks = []
        @after_callbacks = []
        if chain
          chain.each do |cb|
            case cb.kind
            when (:before) then @before_callbacks << cb
            when (:around) then @around_callbacks << cb
            when (:after) then @after_callbacks << cb
            end
          end
        end
        [@before_callbacks, @around_ballbacks, @after_callbacks]
      end
    end

    class Callback
      attr_reader :kind,:filter
      
      def initialize(kind,filter)
        @kind = kind
        @filter = filter
      end

      def invoke(target)
        target.send filter
      end
    end

  end 
end