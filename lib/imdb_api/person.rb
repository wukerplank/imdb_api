module ImdbApi
  class Person < Base

    def self.find(imdb_id)
      doc = CacheFile.person_data(imdb_id)

      name = doc.at('h1.header').at("span.itemprop").inner_html.strip
      name = name.gsub(/^(.*)\s+(\<.*?\>.*?\<\/.*?\>)?$/, "\\1")

      return {imdb_id: imdb_id, name: name}
    end

  end
end
