class BarModel
  include MyMongoid::Document

  field :a
  field :b
end

def config_db
  MyMongoid.configure do |config|
    config.host = "localhost:27017"
    config.database = "my_mongoid_test"
  end
end

def clean_db
  BarModel.collection.drop
end

describe MyMongoid do
  describe "Should be able to configure MyMongoid" do
    describe MyMongoid::Configuration do
      let(:config) {
        MyMongoid::Configuration.instance
      }
      it "should be a singleton class" do
        config_dup = MyMongoid::Configuration.instance
        expect(config).to eq(config_dup)
      end

      it "should have #host accessor" do
        expect(config).to respond_to(:host)
        expect(config).to respond_to(:host=)
      end

      it "should have #database accessor" do
        expect(config).to respond_to(:database)
        expect(config).to respond_to(:database=)
      end
    end

    describe ".configuration" do
      it "should return the MyMongoid::Configuration singleton" do
        expect(MyMongoid.configuration).to be_an_instance_of(MyMongoid::Configuration)
      end
    end

    describe ".configure" do
      let(:config) {
        MyMongoid::Configuration.instance
      }

      it "should yield MyMongoid.configuration to a block" do
        rtn = MyMongoid.configure do |config|
                config
              end
        expect(rtn).to eq(config)
      end
    end
  end

  describe "Should be able to get database session" do
    before :all do
      config_db
    end

    describe "MyMongoid.session" do
      let(:session) {
        MyMongoid.session
      }
      it "should return a Moped::Session" do
        expect(session).to be_a(Moped::Session)
      end

      it "should momorize the session @session" do
        another = MyMongoid.session

        expect(session.object_id).to eq(another.object_id)
      end

      it "should raise MyMongoid::UnconfiguredDatabaseError if host and database are not configured" do
        config = MyMongoid.configuration
        config.host = nil
        config.database = nil
        expect {
          MyMongoid.session
        }.to raise_error(MyMongoid::UnconfiguredDatabaseError)
      end
    end
  end

  describe "Should be able to create a record" do
    before :all do
      config_db
    end

    describe "model collection" do
      let(:klass) {
        BarModel
      }
      describe "Model.collection_name" do
        it "should use active support's tableize method" do
          # because klass.name is a String
          expect_any_instance_of(String).to receive(:tableize)
          klass.collection_name
        end
      end

      describe "Model.collection" do
        it "should return a model's collection" do
          expect(klass.collection).to be_a(Moped::Collection)
        end
      end
    end

    describe "#to_document" do
      let (:bar) {
        BarModel.new({ "a" => 10, "b" => 20 })
      }

      it "should be a bson document" do
        expect(bar.to_document).to eq(bar.attributes)
        expect(bar.to_document.to_bson).to be_a(String)
      end
    end

    describe "Model#save" do
      before :all do
        config_db
      end
      before { clean_db }

      let(:attrs) {
        { "id" => 1, "a" => 10, "b" => 20 }
      }

      let(:bar) {
        BarModel.new(attrs)
      }

      context "successful insert:" do
        before do
          @result = bar.save
        end
        it "should insert a new record into the db" do
          expect(BarModel.collection.find().count).to eq(1)
        end

        it "should return true" do
          expect(@result).to be true
        end

        it "should make Model#new_record return false" do
          expect(bar).not_to be_new_record
        end
      end
    end

    describe "Model.create" do
      before do
        config_db
        clean_db
      end

      let(:attrs) {
        { "_id" => 1, "a" => 10, "b" => 20 }
      }
      let(:bar) {
        BarModel.create(attrs)
      }

      it "should return a saved record" do
        expect(bar).to be_a(BarModel)
        expect(bar).not_to be_new_record
        expect(bar.attributes).to eq(attrs)
      end
    end

    context "saving a record with no id" do
      let(:bar) {
        BarModel.new({ "a" => 10 })
      }
      let(:another_bar) {
        BarModel.new({ "a" => 10 })
      }

      before do
        clean_db
        bar.save
        another_bar.save
      end

      it "should generate a random id" do
        expect(BarModel.collection.find({ "_id" => bar.id }).count()).to eq(1)
        # this line exclude the possbility of null id
        expect(bar.id).not_to eq(another_bar.id)
      end
    end
  end

  describe "should be able to find a record" do
    describe "Model.instantiate" do
      let(:attrs) {
        { "id" => "abc", "a" => 10 }
      }
      let(:bar) {
        BarModel.instantiate(attrs)
      }
      it "should return a model instance" do
        expect(bar).to be_a(BarModel)
      end

      it "should return an instance that's not a new_record" do
        expect(bar).not_to be_new_record
      end

      it "should have the given attributes" do
        expect(bar.attributes).to eq(attrs)
      end
    end

    describe "Model.find" do
      let(:attrs) {
        { "_id" => 1, "a" => 10, "b" => 20 }
      }
      before {
        config_db
        clean_db
        BarModel.create(attrs)
      }

      it "should be able to find a record by issuing query" do
        bar = BarModel.find({"_id" => 1})
        expect(bar).to be_a(BarModel)
        expect(bar.attributes).to eq(attrs)
      end

      it "should be able to find a record by issuing shorthand id query" do
        bar = BarModel.find(1)
        expect(bar).to be_a(BarModel)
        expect(bar.attributes).to eq(attrs)
      end

      it "should raise Mongoid::RecordNotFoundError if nothing is found for an id" do
        expect {
          bar = BarModel.find("unknown")
        }.to raise_error(MyMongoid::RecordNotFoundError)
      end
    end
  end

  describe "Should be able to update a record" do
    describe "#changed_attributes" do
      before(:all) { config_db }

      before {
        clean_db
      }

      it "should be an empty hash initially" do
        bar = BarModel.new({})
        expect(bar.changed_attributes).to eq({})
      end

      it "should track writes to attributes" do
        bar = BarModel.create({ "a" => 10, "b" => 20 })
        bar.a = 11
        expect(bar.changed_attributes.keys).to include("a")
      end

      it "should keep the original attribute values" do
        bar = BarModel.create({ "a" => 10, "b" => 20 })
        bar.a = 11
        expect(bar.changed_attributes["a"]).to eq(10)
      end

      it "should not make a field dirty if the assigned value is equaled to the old one" do
        bar = BarModel.create({ "a" => 10, "b" => 20 })
        bar.a = 10
        expect(bar.changed_attributes.keys).not_to include("a")
      end

      context "when we assigned a different value" do
        it "we could 'clean' a field by assigning equaled value" do
          pending
          bar = BarModel.create({ "a" => 10, "b" => 20 })
          bar.a = 11 # make "a" dirty
          bar.a = 10 # this should make "a" clean
          expect(bar.changed_attributes.keys).not_to include("a")
        end
      end

    end

    context "updating database" do
      before(:all) { config_db }

      let(:barr) {
        BarModel.create({ "a" => 1 })
      }

      describe "#save" do
        it "should have no changes right after persisting" do
          bar = BarModel.create({ "a" => 1 })
          expect(bar).not_to be_changed
        end

        it "should save the changes if a document is already persisted" do
          barr.a = 2
          barr.save
          count = BarModel.collection.find({ "a" => 2 }).count()
          expect(count).to eq(1)
        end
      end

      describe "#update_document" do
        it "should not issue query if nothing changed" do
          barr.a = 1
          barr.update_document
          expect_any_instance_of(Moped::Query).not_to receive(:update)
        end

        it "should update the document in database if there are changes" do
          barr.a = 3
          barr.update_document
          count = BarModel.collection.find({ "a" => 3 }).count()
          expect(count).to eq(1)
        end
      end

      describe "#update_attributes" do
        it "should change and persist attributes of a record" do
          barr.update_attributes({ "a" => 4 })
          count = BarModel.collection.find({ "a" => 4 }).count()
          expect(count).to eq(1)
        end
      end
    end

    describe "#atomic_updates" do
      before(:all) { config_db }
      it "should return {} if nothing changed" do
        bar = BarModel.create({ "a" => 1 })
        expect(bar.atomic_updates).to eq({})
      end

      it "should return {} if record is not a persisted document" do
        bar = BarModel.new({ "a" => 10 })
        expect(bar.atomic_updates).to eq({})
      end

      it "should generate the $set update operation to update a persisted document" do
        bar = BarModel.create({ "a" => 1 })
        bar.a = 2
        expect(bar.atomic_updates["$set"]).to eq({ "a" => 2 })
      end
    end
  end

  describe "Should track changes made to a record" do
    describe "#changed?" do
      before(:all) { config_db }

      it "should be false for a newly instantiated record" do
        bar = BarModel.new({ "a" => 1 })
        expect(bar).not_to be_changed
      end

      it "should be true if a field changed" do
        bar = BarModel.create({ "a" => 1 })
        another_bar = BarModel.create({ "a" => 1 })
        bar.a = 2; another_bar.a = 1
        expect(bar).to be_changed
        expect(another_bar).not_to be_changed
      end
    end
  end

  describe "Should be able to delete a record" do
    describe "#delete" do
      before(:all) {
        config_db
      }

      let(:bar) {
        BarModel.create({ "a" => 1 })
      }
      it "should delete a record from db" do
        id = bar.id
        expect(BarModel.collection.find({ "_id" => id }).count()).to eq(1)
        bar.delete
        expect(BarModel.collection.find({ "_id" => id }).count()).to eq(0)
      end

      it "should return true for deleted?" do
        bar.delete
        expect(bar).to be_deleted
      end
    end
  end

end
