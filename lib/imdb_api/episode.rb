# encoding: UTF-8

module ImdbApi
  class Episode < Base

    def self.find(imdb_id)
      data             = get_information(imdb_id)
      data[:cast]      = get_cast(imdb_id)
      data[:directors] = get_directors(imdb_id)

      return data
    end

  private
    def self.get_directors(imdb_id)
      doc = CacheFile.movie_cast(imdb_id)

      directings = []

      dir_as = doc.search("div#fullcredits_content").search('a').select{|a| a['href'].match(/.*ttfc_fc_dr\d+.*/)}

      if dir_as
        dir_as.each do |a|
          begin

            imdb_id = a['href'].gsub(/.*\/name\/(nm\d+)\/.*/, "\\1")

            directings << {imdb_id: imdb_id}
          rescue Exception => e
            puts "Error with movie #{self.id}:"
            puts e
            puts row
          end
        end
      end

      return directings
    end

    def self.get_cast(imdb_id)
      doc = CacheFile.movie_cast(imdb_id)

      cast = []

      cast_rows = ((doc/'table.cast_list')/'tr')

      cast_rows.each do |row|
        begin
          name_link = row.search('a')[1]
          next if name_link.nil?

          name = name_link.inner_text.strip

          imdb_id = name_link['href'].gsub(/.*(nm\d+).*/i, "\\1")

          role_td = row.search('td')[3]
          if role_link = role_td.search('a').first
            role = role_link
          else
            role = role_td
          end

          role = role.inner_text.strip.gsub(/[\r\n]/, " ").squeeze(" ")

          name = fix_encoding(name)
          role = fix_encoding(role)

          cast << {
            :imdb_id        => imdb_id,
            :credited_as    => name,
            :character_name => role
          }
        end
      end

      return cast
    end

    def self.get_information(imdb_id)
      doc = CacheFile.movie_data(imdb_id)

      data = {}

      if title = doc.at('div.title_wrapper h1')
        data[:title] = title.inner_text.gsub(/[[:space:]]/, " ").strip
      elsif title = doc.at('meta[property="og:title"]')
        data[:title] = title['content'].gsub(/^(.*)\s+\(.*?(\d{4})\).*$/, "\\1")
        data[:year]  = title['content'].gsub(/^(.*)\s+\(.*?(\d{4})\).*$/, "\\2")
      end

      data[:imdb_id] = imdb_id.strip

      return data
    end
  end
end
