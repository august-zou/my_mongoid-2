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
    describe "MyMongoid.session" do
      let(:session) {
        MyMongoid.session(["localhost:27017"], :database => "admin")
      }
      it "should return a Moped::Session" do
        expect(session).to be_a(Moped::Session)
      end

      it "should momorize the session @session" do
        another = MyMongoid.session(["localhost:27017"], :database => "admin")

        expect(session.object_id).to eq(another.object_id)
      end

      it "should raise MyMongoid::UnconfiguredDatabaseError if host and database are not configured" do
        expect {
          MyMongoid.session
        }.to raise_error(MyMongoid::UnconfiguredDatabaseError)
      end
    end
  end
end

