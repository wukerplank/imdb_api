# encoding: UTF-8

module ImdbApi
  class Movie < Base

    def self.find(imdb_id)
      data             = get_information(imdb_id)
      data[:cast]      = get_cast(imdb_id)
      data[:directors] = get_directors(imdb_id)

      return data
    end

  private

# ---------------------------------------------------------------------------------------------------------------------
# Directors
# ---------------------------------------------------------------------------------------------------------------------

    def self.get_directors(imdb_id)
      doc = CacheFile.movie_cast(imdb_id)

      director_section = doc.search("section.ipc-page-section")
        .detect { |section| section.at("div.ipc-title")&.inner_text&.strip&.match(/\ADirector/) }

      if director_section
        return get_directors_from_page_section(director_section)
      elsif doc.search("div[data-testid=sub-section-director]").length > 0
        return get_directors_from_divs(doc)
      elsif doc.search("table.simpleTable")
        return get_directors_from_table(doc)
      end

      return []
    end

    def self.get_directors_from_page_section(director_section)
      directings = []

      director_section.search("ul li").each do |row|
        name_link = row.search('a').detect { |a| a['href']&.match(%r{/name/nm\d+}) && a.inner_text.strip.length > 0 }
        next if name_link.nil?

        imdb_id = name_link['href'].gsub(/.*(nm\d+).*/i, "\\1")
        directings << {imdb_id: imdb_id}
      end

      return directings
    end

    def self.get_directors_from_table(doc)
      directings = []

      dir_as = doc.search("td.name")
        .search('a').select{|a| a['href'].match(/.*ref_=ttfc_fc_dr\d+.*/)}
        .uniq { |a| a['href'] }

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

    def self.get_directors_from_divs(doc)
      directings = []

      dir_as = doc.search("div[data-testid=sub-section-director]")
        .search('li')
        .search('a').select{|a| a['href'].match(/.*ref_=ttfc_dr_\d+.*/)}
        .uniq { |a| a['href'] }

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

# ---------------------------------------------------------------------------------------------------------------------
# Cast
# ---------------------------------------------------------------------------------------------------------------------
    def self.get_cast(imdb_id)
      doc = CacheFile.movie_cast(imdb_id)

      cast_section = doc.search("section.ipc-page-section")
        .detect { |section| section.at("div.ipc-title")&.inner_text&.strip&.match(/\ACast/) }

      if cast_section
        return get_cast_from_page_section(cast_section)
      elsif doc.at("section[data-testid=title-cast]")
        return get_cast_from_div(doc)
      elsif doc.at('table.cast_list')
        return get_cast_from_table(doc)
      end

      return []
    end

    def self.get_cast_from_page_section(cast_section)
      cast = []

      cast_section.search("ul li").each do |row|
        begin
          name_link = row.search('a').detect { |a| a['href']&.match(%r{/name/nm\d+}) && a.inner_text.strip.length > 0 }
          next if name_link.nil?

          name    = name_link.inner_text.strip
          imdb_id = name_link['href'].gsub(/.*(nm\d+).*/i, "\\1")

          if role_link = row.search('a').detect { |a| a['href']&.match(%r{/characters/}) }
            role = role_link.inner_text.strip.gsub(/[\r\n]/, " ").squeeze(" ")
          else
            role = ""
          end

          name = fix_encoding(name)
          role = fix_encoding(role)

          cast << {
            imdb_id: imdb_id,
            credited_as: name,
            character_name: role
          }
        end
      end

      return cast
    end

    def self.get_cast_from_table(doc)
      cast = []
      cast_rows = doc.search('table.cast_list/tr')

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
            imdb_id: imdb_id,
            credited_as: name,
            character_name: role
          }
        end
      end

      return cast
    end


    def self.get_cast_from_div(doc)
      cast = []

      cast_rows = ((doc / 'div[data-testid=sub-section-cast]') / 'li')

      cast_rows.each do |row|
        begin
          name_link = row.search('a')[1]
          next if name_link.nil?

          name = name_link.inner_text.strip

          imdb_id = name_link['href'].gsub(/.*(nm\d+).*/i, "\\1")

          if role_link = row.search('a').detect { |a| a['href'].match(/.*\/characters\/.*/) }
            role = role_link
            role = role.inner_text.strip.gsub(/[\r\n]/, " ").squeeze(" ")
          else
            role = ""
          end

          name = fix_encoding(name)
          role = fix_encoding(role)

          cast << {
            imdb_id: imdb_id,
            credited_as: name,
            character_name: role
          }
        end
      end

      return cast
    end

# ---------------------------------------------------------------------------------------------------------------------
# Information
# ---------------------------------------------------------------------------------------------------------------------

    def self.get_information(imdb_id)
      doc = CacheFile.movie_data(imdb_id)

      data = {}

      if title = doc.at('h1.header')
      elsif title = doc.at('meta[property="og:title"]')
        data[:title] = title['content'].gsub(/^(.*)\s+\(.*?(\d{4})\).*$/, "\\1")
        data[:year]  = title['content'].gsub(/^(.*)\s+\(.*?(\d{4})\).*$/, "\\2")
      end

      if (title / '.title-extra').length > 0
        data[:title] = (title / '.title-extra').children.first.text.strip.gsub(/\A"(.*)"\z/, "\\1")
        year = (title.at('.nobr/a') || title.at('.nobr')).inner_text.strip
        data[:year]  = year.gsub(/[\(\)]/, "")
      elsif (title / '.itemprop').detect{|s| s['itemprop']=='name'}
        data[:title] = (title / '.itemprop').detect{|s| s['itemprop']=='name'}.inner_text.strip
        year = (title.at('.nobr/a') || title.at('.nobr')).inner_text.strip
        data[:year]  = year.gsub(/[\(\)]/, "")
      # else
      #   data[:title] = title.children.first.inner_text.strip
      #   data[:year]  = (title / 'span/a').first.inner_text.strip
      end

      data[:imdb_id] = imdb_id.strip

      return data
    end
  end
end
