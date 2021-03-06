require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Enumlogic" do

  it "should have a constant" do
    Computer.enum :kind, ["apple", "dell", "hp"], :namespace => true
    Computer::KINDS.should == ["apple", "dell", "hp"]
  end

  it "constant should always return an array" do
    hash = ActiveSupport::OrderedHash.new
    hash["apple"] = "Apple"
    hash["dell"] = "Dell"
    hash["hp"] = "HP"

    Computer.enum :kind, hash, :namespace => true
    Computer::KINDS.should == ["apple", "dell", "hp"]
  end

  it "should create a class level options method" do
    Computer.enum :kind, ["apple", "dell", "hp"]
    Computer.kind_options.should == {"apple" => "apple", "dell" => "dell", "hp" => "hp"}
  end

  it "should create a class level options method for hashes" do
    Computer.enum :kind, {"apple" => "Apple", "dell" => "Dell", "hp" => "HP"}
    Computer.kind_options.should == {"Apple" => "apple", "Dell" => "dell", "HP" => "hp"}
  end

  it "should accept symbols as well as strings" do
    Computer.enum :kind, [:apple, :dell, :hp]
    Computer.kind_options.should == {"apple" => :apple, "dell" => :dell, "hp" => :hp}
  end

  it "should accept symbols as well as strings for hashes" do
    Computer.enum :kind, {:apple => "Apple", :dell => "Dell", :hp => "HP"}
    Computer.kind_options.should == {"Apple" => :apple, "Dell" => :dell, "HP" => :hp}
  end

  it "should create key methods" do
    Computer.enum :kind, ["apple", :dell, "hp"]
    c = Computer.new(:kind => "apple")
    c.kind_key.should == :apple
    d = Computer.new(:kind => :dell)
    d.kind_key.should == :dell
  end

  it "should create int methods" do
    Computer.enum :kind, ["apple", :dell, "hp", "lenovo"]
    c = Computer.new(:kind => "lenovo")
    c.kind_int.should == Zlib.crc32('lenovo') / 100_000
    d = Computer.new(:kind => :dell)
    d.kind_int.should == Zlib.crc32('dell') / 100_000
  end

  it "should create key methods for hashes" do
    Computer.enum :kind, {"apple" => "Apple", "dell" => "Dell", "hp" => "HP"}
    c = Computer.new(:kind => "apple")
    c.kind_key.should == :apple
    d = Computer.new(:kind => :dell)
    d.kind_key.should == :dell
  end

  it "should create text methods" do
    Computer.enum :kind, [ "apple", :dell, "hp" ]
    c = Computer.new(:kind => "hp")
    c.kind_text.should == "hp"
    d = Computer.new(:kind => :dell)
    d.kind_text.should == "dell"
  end

  it "should create text methods for hashes" do
    Computer.enum :kind, {"apple" => "Apple", :dell => "Dell", "hp" => "HP"}
    c = Computer.new(:kind => "hp")
    c.kind_text.should == "HP"
    d = Computer.new(:kind => :dell)
    d.kind_text.should == "Dell"
  end

  it "should create text method which results nil for wrong key" do
    Computer.enum :kind, {"apple" => "Apple", "dell" => "Dell", "hp" => "HP"}
    c = Computer.new :kind => 'ibm'
    c.kind_text.should == nil
  end

  it "should create boolean methods" do
    Computer.enum :kind, ["apple", :dell, "hp"]
    c = Computer.new(:kind => "apple")
    c.should be_apple
    d = Computer.new(:kind => :dell)
    d.should be_dell
  end

  it "should namespace boolean methods" do
    Computer.enum :kind, ["apple", :dell, "hp"], :namespace => true
    c = Computer.new(:kind => "apple")
    c.should be_apple_kind
    d = Computer.new(:kind => :dell)
    d.should be_dell_kind
  end

  it "should create reader methods" do
    Computer.enum :kind, ["apple", "dell", "hp"]
    c = Computer.new(:kind => "apple")
    c.kind.should == "apple"
  end

  it "should validate inclusion" do
    Computer.enum :kind, ["apple", "dell", "hp"]
    c = Computer.new
    c.kind = "blah"
    c.should_not be_valid
    c.errors[:kind].should include("is not included in the list")
  end

  it "should allow nil during validations" do
    Computer.enum :kind, ["apple", "dell", "hp"], :allow_nil => true
    c = Computer.new
    c.should be_valid
  end

  it 'should allow blank during validations' do
    Computer.enum :kind, ["apple", "dell"], :allow_blank => true
    c = Computer.new(:kind => "")
    c.should be_valid
    c.kind.should == nil
  end

  it "should find a defined enum" do
    Computer.enum :kind, ["apple", "dell", "hp"]

    Computer.enum?(:kind).should == true
    Computer.enum?(:some_other_field).should == false
  end

  it "should check for defined enums if there isn't any" do
    Computer.enum?(:kind).should == false
  end

  it "should save integer to db" do
    Car.enum :model, ['tesla', :bmw, 'moskvich']
    Car.new(:model => 'tesla').save.should be_true
    Car.connection.execute("select * from cars").first['model'].to_i.should == Zlib.crc32('tesla') / 100_000
    Car.first.model_key.should  == :tesla
    Car.first.model_text.should == 'tesla'
    Car.first.model_int.should  == Zlib.crc32('tesla') / 100_000
  end

  it 'should convert enum value to integer Klass.enum_int_for(val)' do
    Car.enum :model, ['tesla', :bmw, 'moskvich']
    Car.enum_int_for('tesla').should == Zlib.crc32('tesla') / 100_000
    Car.enum_int_for(:tesla).should  == Zlib.crc32('tesla') / 100_000

    # DEPRECATED but still tested
    Car.model_value('tesla').should == Zlib.crc32('tesla') / 100_000
    Car.model_value(:tesla).should  == Zlib.crc32('tesla') / 100_000
  end

  describe 'enum value validations' do
    it "should accept :allow_nil parameter for enum values validation" do
      Car.enum :model, ['tesla', :bmw, 'moskvich'], :allow_nil => true
      car = Car.new(:model => nil)
      car.save.should be_true
      car.tesla?.should_not raise_error(ArgumentError)
      car.should_not be_tesla
      car.should_not be_bmw
      car.should_not be_moskvich
    end
  end
end
