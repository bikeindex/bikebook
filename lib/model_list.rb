module BikeBook
  class ModelList < Sinatra::Base

    before do
      response.headers["access-control-allow-origin"] = "*"
      response.headers['access-control-allow-headers'] = 'Origin, X-Requested-With, Content-Type, Accept, Authorization'
      response.headers['access-control-allow-methods'] = "GET, OPTIONS"
      response.headers['access-control-request-method'] = "*"
    end
    
    get '/' do 
      content_type :json
      f = "./bike_data/"
      pass unless params[:manufacturer].present?
      f += "#{Slugify.input(params[:manufacturer])}/"
      if params[:year].present?
        f += "#{params[:year]}/"
      end
      f += "/model_list.json" 
      pass unless File.exists?(f)
      File.read(f)
    end

    not_found do
      content_type :json
      {
        code: 404,
        message: "Shucks, no we couldn't find that",
        description: "View all bikes: #{request.base_url} or documentation: #{request.base_url}/documentation"
      }.to_json
    end
  end
end
