# encoding: UTF-8

module ImdbApi
  class Movie < Base

    def self.find(imdb_id)
      title_data   = ApiClient.get_title(imdb_id)
      credits_data = ApiClient.get_title_credits(imdb_id)

      data             = {}
      data[:imdb_id]   = imdb_id
      data[:title]     = title_data['title']
      data[:year]      = extract_year(title_data)
      data[:directors] = extract_directors(credits_data)
      data[:cast]      = extract_cast(credits_data)

      return data
    end

  private

    def self.extract_year(title_data)
      release_date = title_data['release_date']
      return nil if release_date.nil? || release_date.empty?

      release_date[0, 4]
    end

    def self.extract_directors(credits)
      (credits['crew'] || [])
        .select { |c| c['job'] == 'Director' }
        .filter_map { |c| c['id'] && {imdb_id: c['id']} }
    end

    def self.extract_cast(credits)
      (credits['cast'] || []).filter_map do |credit|
        next if credit['id'].nil?

        {
          imdb_id:        credit['id'],
          credited_as:    credit['name'],
          character_name: credit['character'].to_s
        }
      end
    end

  end
end
