# encoding: utf-8
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

    it "should remove diacritics and bicycles, because people just put them in everything" do 
      slug = Slugify.input('paké rum runner')
      slug.should eq('pake_rum_runner')
    end

    it "should change + to plus for URL safety, and Trek uses + to differentiate" do 
      slug = Slugify.input("L100+ Lowstep BLX")
      slug.should eq('l100plus_lowstep_blx')
    end
  end
end