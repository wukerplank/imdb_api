module ImdbApi
  class CacheFile
  
    def self.agent
      @@agent ||= self.initialize_agent
      return @@agent
    end

    def self.initialize_agent
      a = Mechanize.new
      a.user_agent_alias = 'Mac Safari'
      return a
    end
  
    def self.movie_cast(imdb_id, options={})
      options[:force] ||= false
    
      return get("http://akas.imdb.com/title/#{imdb_id}/fullcredits", "movies/cast/#{imdb_id}_cast.html.gz", options)
    end
  
    def self.movie_data(imdb_id, options={})
      options[:force] ||= false
    
      return get("http://akas.imdb.com/title/#{imdb_id}", "movies/info/#{imdb_id}_movie.html.gz", options)
    end
  
    def self.person_data(imdb_id, options={})
      options[:force] ||= false
    
      return get("http://akas.imdb.com/name/#{imdb_id}", "people/#{imdb_id}.html.gz", options)
    end
  
  private
    def self.get(url, path, options={})
      path = File.join('/Users/christoph/Sites/mediamaster/imdb_cache', path)
      
      if !File.exist?(path) || options[:force]
        doc = agent.get(url)
        write_cached_file(path, doc.body)
      else
        doc = Nokogiri::HTML.parse(read_cached_file(path))
      end
      
      return doc
    end
  
    def self.write_cached_file(path, content)
      GzFile.open(path) do |f|
        f.write content
      end
    end
  
    def self.read_cached_file(path)
      GzFile.read(path)
    end
  
  end
end