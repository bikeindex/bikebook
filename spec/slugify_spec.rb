require 'spec_helper'

describe Slugify do
  describe :input do 
    it "should remove special characters and downcase" do
      slug = Slugify.input("Surly's Cross-check bike")
      slug.should eq("surly_s_cross_check")
    end

    it "should remove bikes and bicycles, because people just put them in everything" do 
      slug = Slugify.input("Cross-check Singlespeed BicyclE")
      slug.should eq('cross_check_singlespeed')
    end
  end
end