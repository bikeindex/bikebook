
module BikeBook
  class Open < Sinatra::Base

    before do
      response.headers["access-control-allow-origin"] = "*"
      response.headers['access-control-allow-headers'] = 'Origin, X-Requested-With, Content-Type, Accept, Authorization'
      response.headers['access-control-allow-methods'] = "GET, OPTIONS"
      response.headers['access-control-request-method'] = "*"
    end

    get '/' do
      erb File.read('./public/index.erb')
      # content_type :json
        
      # f = "./bike_data/"
      # if params[:manufacturer].present?
      #   f += "#{Slugify.input(params[:manufacturer])}/"
      #   if params[:year].present?
      #     f += "#{params[:year]}/"
      #   end
      # end
      # if params[:frame_model].present?
      #   f += "#{Slugify.input(params[:frame_model])}.json"
      # else
      #   f += "index.json"
      #   puts f
      # end
      # pass unless File.exists?(f)
      # File.read(f)
    end

    get '/site.css' do
      erb File.read('./public/site.css')
    end
    

    get '/documentation' do
      content_type :json
      {
        "what?" => "Find bikes and their base components. This will be improved soon (particularly this documentation)",
        "how?" => "Submit the manufacturer, year and model in the query string. Submit less to get a list of what there is",
        "example?" => "For Surly Cross-Checks from 2013: #{request.base_url}/?year=2013&manufacturer=Surly%20Bikes&model=Cross%20Check",
        "open source?" => "Course. https://github.com/bikeindex/bikebook"
      }.to_json
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
