module BikeBook
  class BookGenerator
    def initialize(base_dir = nil)
      @base_dir = base_dir ||= "./bike_data/"
      @m_hash = model_hash
    end

    def write_indices
      File.open("./public/index.json", "w") { |f| f.write(@m_hash.to_json) }      
      File.open("./public/select_list.json", "w") { |f| f.write(select_list.to_json) }
      
      @m_hash.keys.each do |mnfg|
        mnfg_slug = Slugify.manufacturer(mnfg)
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


    def select_list
      list = {manufacturers: []}
      @m_hash.keys.each do |mnfg|
        list[:manufacturers] << {id: Slugify.manufacturer(mnfg), name: mnfg, years: @m_hash[mnfg].keys.sort.reverse }
      end
      list
    end

    def model_hash
      models = {}
      bike_files.each do |f|
        bf = JSON.parse(File.read(f))
        bike = {
          manufacturer: bf["bike"]["manufacturer"],
          year: bf["bike"]["year"],
          frame_model: bf["bike"]["frame_model"],
          slug: Slugify.input(bf["bike"]["frame_model"]),
          msrp: bf["bike"]["original_msrp"]
        }
        text = bike[:frame_model]
        text += "<span class='f_msrp'>#{bike[:msrp]}</span>" if bike[:msrp]

        models[bike[:manufacturer]] ||= {}
        models[bike[:manufacturer]][bike[:year]] ||= []
        models[bike[:manufacturer]][bike[:year]] << {id: bike[:slug], text: text, name: bike[:frame_model] }
      end
      models
    end

    def model_list(manufacturer, years = @m_hash[manufacturer].keys)
      years = [years] unless years.kind_of?(Array)
      model_list = []      
      years.each do |year|
        puts @m_hash[manufacturer][year]
        @m_hash[manufacturer][year].each { |bike| model_list << bike[:name] }
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