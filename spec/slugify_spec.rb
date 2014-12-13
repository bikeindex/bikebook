# encoding: utf-8
require 'spec_helper'

describe Slugify do
  describe :input do 
    it "should remove special characters and downcase" do
      slug = Slugify.input("Surly's Cross-check bike (small wheel)")
      slug.should eq("surly_s_cross_check_small_wheel")
    end

    it "should remove bikes and bicycles, because people just put them in everything" do 
      slug = Slugify.input("Cross-check Singlespeed BicyclE")
      slug.should eq('cross_check_singlespeed')
    end

    it "should remove diacritics and bicycles, because people just put them in everything" do 
      slug = Slugify.input('paké rum runner')
      slug.should eq('pake_rum_runner')
    end

    it "should change + to plus for URL safety, and Trek uses + to differentiate" do 
      slug = Slugify.input("L100+ Lowstep BLX")
      slug.should eq('l100plus_lowstep_blx')
    end
  end

  describe :manufacturer do 
    it "should remove works rivendell" do 
      slug = Slugify.manufacturer("Rivendell Bicycle Works")
      slug.should eq('rivendell')      
    end
    it "should remove frameworks for legacy" do 
      slug = Slugify.manufacturer("Legacy Frameworks")
      slug.should eq('legacy')      
    end
    it "should remove bicycle company for Kona" do 
      slug = Slugify.manufacturer("Kona Bicycle Company")
      slug.should eq('kona')
    end
    it "does not remove haibike" do 
      slug = Slugifyer.manufacturer("Haibike (Currietech)")
      slug.should eq('haibike')      
    end
    it "should not remove WorkCycles" do 
      slug = Slugify.manufacturer("WorkCycles")
      slug.should eq('workcycles')
    end
    it "should not remove worksman" do 
      slug = Slugify.manufacturer("Worksman Cycles")
      slug.should eq('worksman')
    end
  end
  
end