# encoding: utf-8
class Slugify
  def self.input(string)
    slug = I18n.transliterate(string.downcase)
    key_hash = {
      '\s(bi)?cycles?|bikes?' => ' ',
      '\+'                   => 'plus',
      '([^A-Za-z0-9])'      => ' '
    }
    key_hash.keys.each do |k|
      slug.gsub!(/#{k}/i, key_hash[k])
    end
    slug.strip.gsub(/\s+/,'_') # strip and then turn any length of spaces into underscores
  end

  def self.manufacturer(string)
    input(string.gsub(/\sco(\.|mpany)/i,' ').gsub(/\s(frame)?works/i,' '))
  end
end
