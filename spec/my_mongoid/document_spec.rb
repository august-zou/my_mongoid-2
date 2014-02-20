# spec/my_mongoid/document_spec.rb

class Event
  include MyMongoid::Document
  field :public
  field :created_at
end

class FooModel
  include MyMongoid::Document
  field :number
  def number=(n)
    self.attributes["number"] = n + 1
  end
end


describe MyMongoid::Document do
  let(:attributes) {
    {"public" => true, "created_at" => Time.parse("2014-02-13T03:20:37Z")}
  }

  let(:event) {
    Event.new(attributes)
  }

  let(:foo) {
    FooModel.new({})
  }

  describe ".new" do
    it "can instantiate a model with attributes" do
      expect(event).to be_an(Event)
    end

    it "throws an error if attributes it not a Hash" do
      expect {
        Event.new(100)
      }.to raise_error(ArgumentError)
    end
  end

  describe "#read_attribute" do
    it "can get an attribute with #read_attribute" do
      expect(event.read_attribute("public")).to eq(true)
    end
  end

  describe "#write_attribute" do
    it "can set an attribute with #write_attribute" do
      event.write_attribute("public","false")
      expect(event.read_attribute("public")).to eq("false")
    end
  end

  describe "#process_attributes" do
    it "use field setters for mass-assignment" do
      foo.process_attributes :number => 10
      expect(foo.number).to eq(11)
    end
  end

  describe "#new_record?" do
    it "is a new record initially" do
      expect(event).to be_new_record
    end
  end
end
