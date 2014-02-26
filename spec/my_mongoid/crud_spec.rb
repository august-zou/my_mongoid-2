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
      it "should return a model instance" do
      end

      it "should return an instance that's not a new_record" do
      end

      it "should have the given attributes" do
      end
    end

    describe "Model.find" do
      it "should be able to find a record by issuing query" do
      end

      it "should be able to find a record by issuing shorthand id query" do
      end

      it "should raise Mongoid::RecordNotFoundError if nothing is found for an id" do
      end
    end
  end

end
