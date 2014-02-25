require 'spec_helper'

describe BikeBook::BookGenerator do
  describe :refresh do 
    it "should call write_indices" do 
      bb = BikeBook::BookGenerator.new
      bb.should_receive(:write_indices)
      bb.refresh
    end
  end

  describe :model_hash do
    it "should return a hash with all the different mnfgs and model names" do 
      m_list = BikeBook::BookGenerator.new.model_hash

      m_list["Surly"][2013].count.should eq(15)
      m_list["Surly"][2013].include?({:manufacturer=>"Surly", :year=>2013, :model_name=>"Pugsley"}).should be_true
    end
  end

  describe :write_indices do 
    it "should write the base index, manufacturer index and " do 
      model_hash = {"Surly" =>
        {2013 => [{:manufacturer=>"Surly", :year=>2013, :model_name=>"Big Dummy"}] }
      }
      writer = BikeBook::BookGenerator.new
      File.should_receive(:open).with("./bike_data/index.json", "w")
      File.should_receive(:open).with("./bike_data/surly/index.json", "w")
      File.should_receive(:open).with("./bike_data/surly/2013/index.json", "w")
      writer.write_indices(model_hash)
    end
  end

  describe :bike_files do 
    it "should return a list of all the json bike files" do 
      list = BikeBook::BookGenerator.new.bike_files 
      list.count.should_not be_nil
    end
  end

end