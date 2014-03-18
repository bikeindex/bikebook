module BikeBook
  class BookGenerator
    def initialize(base_dir = nil)
      @base_dir = base_dir ||= "./bike_data/"
      @m_hash = model_hash
    end

    def write_indices
      File.open("#{@base_dir}index.json", "w") do |f|
        f.write(@m_hash.to_json)
      end
      @m_hash.keys.each do |mnfg|
        mnfg_slug = Slugify.input(mnfg)
        File.open("#{@base_dir}#{mnfg_slug}/index.json", "w") do |f|
          f.write(@m_hash[mnfg].to_json)
        end
        File.open("#{@base_dir}#{mnfg_slug}/model_list.json", "w") do |f|
          f.write(model_list(mnfg).to_json)
        end
        
        @m_hash[mnfg].keys.reverse_each do |year|
          File.open("#{@base_dir}#{mnfg_slug}/#{year}/index.json", "w") do |f|
            f.write(@m_hash[mnfg][year].to_json)
          end
          File.open("#{@base_dir}#{mnfg_slug}/#{year}/model_list.json", "w") do |f|
            f.write(model_list(mnfg, year).to_json)
          end
        end
      end
    end

    def model_hash
      models = {}
      bike_files.each do |f|
        bf = JSON.parse(File.read(f))
        bike = {
          manufacturer: bf["bike"]["manufacturer"],
          year: bf["bike"]["year"],
          frame_model: bf["bike"]["frame_model"]
        }

        models[bike[:manufacturer]] ||= {}
        models[bike[:manufacturer]][bike[:year]] ||= []
        models[bike[:manufacturer]][bike[:year]] << bike[:frame_model]
      end
      models
    end

    def model_list(manufacturer, years = @m_hash[manufacturer].keys)
      years = [years] unless years.kind_of?(Array)
      model_list = []      
      years.each do |year|
        puts @m_hash[manufacturer][year]
        @m_hash[manufacturer][year].each { |bike| model_list << bike }
      end
      model_list.uniq
    end

    def bike_files
      files = Dir.glob("#{@base_dir}**/*.json")
      files.reject!{ |i| i[/index.json$/] }
      files.reject!{ |i| i[/model_list.json$/] }
      files
    end

  end
end