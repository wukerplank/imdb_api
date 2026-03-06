module ImdbApi
  class Person < Base

    def self.find(imdb_id)
      data = ApiClient.get_name(imdb_id)
      {imdb_id: imdb_id, name: data['displayName']}
    end

  end
end
