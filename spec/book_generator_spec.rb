require 'spec_helper'

describe BikeBook::BookGenerator do
  describe :model_hash do
    it "should return a hash with all the different mnfgs and model names" do 
      m_list = BikeBook::BookGenerator.new.model_hash

      m_list["Surly"][2014].count.should eq(20)
      m_list["Surly"][2014].include?("Pugsley").should be_true
    end
  end

  describe :select_list do 
    it "should write the things we need" do 
      select_list = BikeBook::BookGenerator.new.select_list
      select_list["manufacturers"].include? ({"Globe"=>[2014]}).should be_true
    end
  end

  describe :write_indices do 
    xit "should write the base index, manufacturer index and model lists" do 
      model_hash = {"Surly" =>
        {2013 => [{:manufacturer=>"Surly", :year=>2013, :model_name=>"Big Dummy"}] }
      }
      writer = BikeBook::BookGenerator.new
      File.should_receive(:open).with("./public/index.json", "w")
      File.should_receive(:open).with("./public/select_list.json", "w")
      File.should_receive(:open).with("./bike_data/surly/index.json", "w")
      File.should_receive(:open).with("./bike_data/surly/2013/index.json", "w")
      File.should_receive(:open).with("./bike_data/surly/model_list.json", "w")
      File.should_receive(:open).with("./bike_data/surly/2013/model_list.json", "w")
      writer.write_indices
    end
  end

  describe :bike_files do 
    it "should return a list of all the json bike files" do 
      list = BikeBook::BookGenerator.new.bike_files 
      list.count.should_not be_nil
    end
  end

end