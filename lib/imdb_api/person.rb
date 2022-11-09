module ImdbApi
  class Person < Base

    def self.find(imdb_id)
      doc = CacheFile.person_data(imdb_id)
      raw_data = doc.at("script[type='application/ld+json']")
      data = JSON.parse(raw_data)
      name = data["name"]

      return {imdb_id: imdb_id, name: name}
    end

  end
end
