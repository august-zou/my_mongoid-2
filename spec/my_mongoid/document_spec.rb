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

    it "can declare a field using the 'field' DSL" do
      expect(Event).to be_a(Class)
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

  describe "#fields_accessor" do
    it "declares getter for a field" do
      expect(event).to respond_to(:public)
      expect(event.public).to eq(attributes["public"])
    end

    it "declares setter for a field" do
      expect(event).to respond_to(:public=)
      event.public = false
      expect(event.public).to eq(false)
      expect(event.read_attribute("public")).to eq(false)
    end
  end

  context ".fields" do
    let(:fields) {
      Event.fields
    }

    it "maintains a map fields objects" do
      expect(fields).to be_a(Hash)
      expect(fields.keys).to include(*%w(public created_at))
    end

    it "returns a string for Field#name" do
      field = fields["public"]
      expect(field).to be_a(MyMongoid::Field)
      expect(field.name).to eq("public")
    end
  end

  it "raises MyMongoid::DuplicateFieldError if field is declared twice" do
    expect {
      Event.module_eval do
        field :public
      end
    }.to raise_error(MyMongoid::DuplicateFieldError)
  end

  it "automatically declares the '_id' field"  do
    expect(Event.fields.keys).to include("_id")
  end

  context ".attributes" do
    let(:foo) {
      FooModel.new({})
    }
    it "use field setters for mass-assignment" do
      foo.process_attributes :number => 10
      expect(foo.number).to eq(11)
    end

    it "raise MyMongoid::UnknownAttributeError if the attributes Hash contains undeclared fields." do
      expect {
        foo.process_attributes :unkonwn => 10
      }.to raise_error(MyMongoid::UnknownAttributeError)
    end

    it "aliases #process_attributes as #attribute=" do
      foo.attributes = {:number => 10}
      expect(foo.number).to eq(11)
    end

    it "uses #process_attributes for #initialize" do
      foo = FooModel.new({:number => 10})
      expect(foo.number).to eq(11)
    end
  end

  context "Field options" do
    let(:model) {
      Class.new do
        include MyMongoid::Document
        field :number, :as => :n
      end
    }

    it "accepts hash options for the field keyword" do
      expect {
        model
      }.to_not raise_error
    end

    it "stores the field options in Field object" do
      expect(model.fields["number"].options).to eq(:as => :n)
    end

    it "aliases a field with the :as option" do
      record = model.new(number: 10)
      expect(record.number).to eq(10)
      expect(record.n).to eq(10)
      record.n = 20
      expect(record.number).to eq(20)
      expect(record.n).to eq(20)
    end

    it "by default aliases '_id' as 'id'" do
      record = model.new({})
      record.id = "abc"
      expect(record._id).to eq("abc")
    end
  end
end
