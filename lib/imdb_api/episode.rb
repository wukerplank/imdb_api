# encoding: UTF-8

module ImdbApi
  class Episode < Base

    def self.find(imdb_id)
      title_data   = ApiClient.get_title(imdb_id)
      credits_data = ApiClient.get_title_credits(imdb_id)

      data             = {}
      data[:imdb_id]   = imdb_id
      data[:title]     = title_data['primaryTitle']
      data[:year]      = title_data['startYear']&.to_s
      data[:number]    = nil  # not available from /titles/{id} endpoint
      data[:directors] = extract_directors(title_data)
      data[:cast]      = extract_cast(credits_data)

      return data
    end

  private

    def self.extract_directors(title_data)
      (title_data['directors'] || []).map { |d| {imdb_id: d['id']} }
    end

    def self.extract_cast(credits)
      credits
        .select { |c| ['actor', 'actress'].include?(c['category']) }
        .filter_map do |credit|
          name = credit['name']
          next if name.nil?

          {
            imdb_id:        name['id'],
            credited_as:    name['displayName'],
            character_name: (credit['characters'] || []).join(', ')
          }
        end
    end

  end
end
