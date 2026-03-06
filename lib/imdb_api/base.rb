module ImdbApi
  class Base

    def self.cache_directory=(cache_directory)
      @@cache_directory = cache_directory
    end

    def self.cache_directory
      @@cache_directory
    end

  end
end
