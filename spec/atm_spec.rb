require 'atm'

# the hook should be like this:
#
# class ATM
#   # the following line should call log method after deposit action
#   command_after :deposit, :log
# end

describe ATM do
  before(:all) {
    class ATM
      define_atm_callbacks :deposit, :withdraw
    end
  }
  describe "declare callback hooks" do
    let(:klass) {
      ATM
    }
    before(:each) {
      class ATM
        reset_callbacks :deposit
      end
    }

    it "should be able to register a :command_before callback" do
      expect {
        klass.class_eval do
          command_before :deposit, :log
        end
      }.not_to raise_error
    end

    it "should be able to register a :command_after callback" do
      expect {
        klass.class_eval do
          command_after :deposit, :log
        end
      }.not_to raise_error
    end

    it "should be able to register a :command_around callback" do
      expect {
        klass.class_eval do
          command_around :deposit, :log
        end
      }.not_to raise_error
    end
  end

  describe "logging concern" do
    let(:klass) { ATM }

    let(:account) { Account.new(2000) }

    let(:atm) { ATM.new(account) }

    before(:each) {
      class ATM
        reset_callbacks :deposit
      end
    }

    it "should log around #deposit" do
      ATM.class_eval do
        command_around :deposit, ->(r, &block) { log("before log"); block.call; log("after log") }
      end

      expect(atm).to receive(:log).ordered
      expect(account).to receive(:deposit).ordered
      expect(atm).to receive(:log).ordered
      atm.deposit(100)
    end
  end

  describe "text notification concern" do
    let(:klass) { ATM }

    let(:account) { Account.new(2000) }

    let(:atm) { ATM.new(account) }

    before(:each) {
      class ATM
        reset_callbacks :deposit
      end
    }

    it "should invoke #send_sms after #deposit" do
      ATM.class_eval do
        command_after :deposit, :send_sms
      end

      expect(account).to receive(:deposit).ordered
      expect(atm).to receive(:send_sms).ordered
      atm.deposit(100)
    end
  end

  describe "authentication concern" do

    before(:each) do
      ATM.class_eval do
        reset_callbacks :deposit
        command_before :deposit, :valid_access?
      end
    end

    context "account.valid_access? returns true" do

      let(:account) {
        Account.new(1000)
      }

      let(:atm) {
        ATM.new(account)
      }
      it "should call Account#deposit" do
        expect(account).to receive(:deposit)
        atm.deposit(100)
      end
    end

    context "account.valid_access? returns false" do
      let(:account) {
        Account.new(1000, false)
      }

      let(:atm) {
        ATM.new(account)
      }
      it "should cancel #deposit" do
        expect(account).not_to receive(:deposit)
        atm.deposit(100)
      end

      it "should cancel after callbacks" do
        ATM.send :command_after, :deposit, :send_sms
        expect(account).not_to receive(:send_sms)
        atm.deposit(100)
      end
    end

  end

end
