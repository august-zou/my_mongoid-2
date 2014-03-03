
class MyEvent
  include MyMongoid::Document

  field :public
  field :created_at

  before_save :save_foo
  
  before_create :create_foo


  def save_foo
  end

  def create_foo
  end

  def foo
  end
end

def config_db
  MyMongoid.configure do |config|
    config.host = "localhost:27017"
    config.database = "my_mongoid_test"
  end
end

def clean_my_event_db
  MyEvent.collection.drop
end

describe MyMongoid do
  describe "all hooks" do
    it "should declare before hook for delete" do
      expect {
        MyEvent.module_eval do
          before_delete :foo
        end
        }.to_not raise_error
    end


    it "should declare around hook for delete" do
      expect {
        MyEvent.module_eval do
          around_delete :foo
        end
        }.to_not raise_error
    end


    it "should declare after hook for delete" do
      expect {
        MyEvent.module_eval do
          after_delete :foo
        end
        }.to_not raise_error
    end

    it "should declare before hook for save" do
      expect {
        MyEvent.module_eval do
          before_save :foo
        end
        }.to_not raise_error
    end

    it "should declare around hook for save" do
      expect {
        MyEvent.module_eval do
          around_save :foo
        end
        }.to_not raise_error
    end

    it "should declare after hook for save" do
      expect {
        MyEvent.module_eval do
          after_save :foo
        end
        }.to_not raise_error
    end


    it "should declare before hook for create" do
      expect {
        MyEvent.module_eval do
          before_create :foo
        end
        }.to_not raise_error
    end

    it "should declare around hook for create" do
      expect {
        MyEvent.module_eval do
          around_create :foo
        end
        }.to_not raise_error
    end

    it "should declare after hook for create" do
      expect {
        MyEvent.module_eval do
          after_create :foo
        end
        }.to_not raise_error
    end

    it "should declare before hook for update" do
      expect {
        MyEvent.module_eval do
          before_update :foo
        end
        }.to_not raise_error
    end

    it "should declare around hook for update" do
      expect {
        MyEvent.module_eval do
          around_update :foo
        end
        }.to_not raise_error
    end

    it "should declare after hook for update" do
      expect {
        MyEvent.module_eval do
          after_update :foo
        end
        }.to_not raise_error
    end

    it "should not declare before hook for find" do
      expect {
        MyEvent.module_eval do
          before_find :foo
        end
        }.to raise_error
      end

    it "should not declare around hook for find" do
      expect {
        MyEvent.module_eval do
          around_find :foo
        end
        }.to raise_error
    end

    it "should declare after hook for find" do
      expect {
        MyEvent.module_eval do
          after_find :foo
        end
        }.to_not raise_error
    end

    it "should not declare before hook for initialize" do
      expect {
        MyEvent.module_eval do
          before_initialize :foo
        end
        }.to raise_error
    end

    it "should not declare around hook for initialize" do
      expect {
        MyEvent.module_eval do
          around_initialize :foo
        end
        }.to raise_error
    end


    it "should declare after hook for initialize" do
      expect {
        MyEvent.module_eval do
          after_initialize :foo
        end
        }.to_not raise_error
    end                                     
  end

  describe "run create callbacks" do
    let(:attributes) {
      {"public" => true, "created_at" => Time.parse("2014-02-13T03:20:37Z")}
    }

    let(:my_event){ MyEvent.new(attributes) }

    before(:all){ config_db }
    after(:all){ clean_my_event_db }
    it "should run callbacks when saving a new record" do

      expect(my_event).to receive(:save_foo)
      my_event.save

    end
    it "should run callbacks when creating a new recor" do
      expect( MyEvent.create(attributes)).to receive(:create_foo)

    end
  end

end
