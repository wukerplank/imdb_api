module ImdbApi
  class Person < Base

    def self.find(imdb_id)
      doc = CacheFile.person_data(imdb_id)
      name = doc.at("h1 span.hero__primary-text").inner_text.strip

      return {imdb_id: imdb_id, name: name}
    end

  end
end
