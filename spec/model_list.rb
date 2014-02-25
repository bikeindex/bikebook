require 'spec_helper'

describe BikeBook::ModelList do
  
  def app
    @app ||= BikeBook::ModelList
  end

  describe "GET '/'" do
    it "should be successful" do
      get '/'
      last_response.should be_ok
    end
  end

  describe "GET 'Pugsley'" do
    it "should be successful" do
      get '/?manufacturer=surly&model=Pugsley&year=2013'
      last_response.should be_ok
    end
  end

end
