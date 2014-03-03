require "active_support"

module Callbacks
  extend ActiveSupport::Concern

  included do
    #define_atm_callbacks :deposit, :withdraw
  end

  module ClassMethods
    def define_atm_callbacks(*callbacks)
      options = { :terminator => "result == false" }
      callbacks.each do |callback|
        define_callbacks callback, options
      end

      types = [:before, :after, :around]
      types.each do |type|
        send("_define_command_#{type}_callback", self)
      end
    end

    private

    def _define_command_before_callback(klass)
      klass.class_eval <<-CALLBACK, __FILE__, __LINE__ + 1
        def self.command_before(callback, *args, &block)
          set_callback(callback, :before, *args, &block)
        end
      CALLBACK
    end

    def _define_command_around_callback(klass)
      klass.class_eval <<-CALLBACK, __FILE__, __LINE__ + 1
        def self.command_around(callback, *args, &block)
          set_callback(callback, :around, *args, &block)
        end
      CALLBACK
    end

    def _define_command_after_callback(klass)
      klass.class_eval <<-CALLBACK, __FILE__, __LINE__ + 1
        def self.command_after(callback, *args, &block)
          set_callback(callback, :after, *args, &block)
        end
      CALLBACK
    end

  end
end

class Account
  attr_reader :balance, :valid
  def initialize(balance, valid = true)
    @balance = balance
    @valid = valid
  end

  def deposit(amount)
    @balance += amount
  end

  def withdraw(amount)
    @balance -= amount
  end

  def valid_access?
    @valid
  end
end



class ATM
  include ActiveSupport::Callbacks
  include Callbacks

  attr_reader :account

  #define_callbacks :deposit
  #command_around :deposit, ->(r, &block) { log("before log"); block.call; log("after log") }

  def initialize(account)
    @account = account
  end
end

module ATM::Commands
  def withdraw(amount)
    account.withdraw(amount)
    -amount
  end

  def deposit(amount)
    run_callbacks(:deposit) do
      account.deposit(amount)
    end
    amount
  end
end

module ATM::Authentication
  extend ActiveSupport::Concern

  def valid_access?
    @account.valid_access?
  end
end

module ATM::Logging
  extend ActiveSupport::Concern

  def log(msg)
    puts msg
  end
end

module ATM::SMSNotification
  extend ActiveSupport::Concern

  def send_sms
    puts "send something"
  end
end


module ATM::Concerns
  extend ActiveSupport::Concern

  included do
    include ATM::Commands
    include ATM::Authentication
    include ATM::Logging
    include ATM::SMSNotification
    include ActiveSupport::Callbacks
  end
end

ATM.send :include, ATM::Concerns

#account = Account.new(1000)
#atm = ATM.new(account)

#atm.deposit(100)
