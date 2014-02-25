class Slugify
  def self.input(string)
    string.downcase.gsub(/bicycles?|bikes?/,'').strip.gsub(/\s\s+/, ' ').gsub(/([^A-Za-z0-9])/,'_')
  end
end