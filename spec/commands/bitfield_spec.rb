require 'spec_helper'

describe '#bitfield(*args)' do
  before do
    @key = "mock-redis-test:bitfield"
    @str = [78, 104, -59].pack("C*")
    @redises.set(@key, @str)
  end

  context "with a :get command" do
    it "gets a signed 8 bit value" do
      @redises.bitfield(@key, :get, "i8", 0).should == [78]
      @redises.bitfield(@key, :get, "i8", 8).should == [104]
      @redises.bitfield(@key, :get, "i8", 16).should == [-59]
    end

    it "gets multiple values with multiple command args" do
      @redises.bitfield(@key, :get, "i8", 0, 
                              :get, "i8", 8, 
                              :get, "i8", 16).should == [78, 104, -59]
    end

    it "gets multiple values using positional offsets" do
      @redises.bitfield(@key, :get, "i8", "#0", 
                              :get, "i8", "#1", 
                              :get, "i8", "#2").should == [78, 104, -59]
    end
  end

  context "with a :set command" do
    it "sets the bit values for an 8 bit signed integer" do
      @redises.bitfield(@key, :set, "i8", 0, 63).should == [78]
      @redises.bitfield(@key, :set, "i8", 8, -1).should == [104]
      @redises.bitfield(@key, :set, "i8", 16, 123).should == [-59]

      @redises.bitfield(@key, :get, "i8", 0, 
                              :get, "i8", 8, 
                              :get, "i8", 16).should == [63, -1, 123]

    end

    it "sets multiple values with multiple command args" do
      @redises.bitfield(@key, :set, "i8", 0, 63,
                              :set, "i8", 8, -1,
                              :set, "i8", 16, 123).should == [78, 104, -59]

      @redises.bitfield(@key, :get, "i8", 0, 
                              :get, "i8", 8, 
                              :get, "i8", 16).should == [63, -1, 123]
    end
  end

  context "with an :incrby command" do
    it "returns the incremented by value for an 8 bit signed integer" do
      @redises.bitfield(@key, :incrby, "i8", 0, 1).should == [79]
      @redises.bitfield(@key, :incrby, "i8", 8, -1).should == [103]
      @redises.bitfield(@key, :incrby, "i8", 16, 5).should == [-54]
    end
  end

  context "with a mixed set of commands" do
    it "returns the correct outputs" do
      @redises.bitfield(@key, :set, "i8", 0, 38,
                              :set, "i8", 8, -99,
                              :incrby, "i8", 16, 1,
                              :get, "i8", 0).should == [78, 104, -58, 38]
    end
  end
end