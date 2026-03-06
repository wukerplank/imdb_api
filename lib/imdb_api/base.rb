module ImdbApi
  class Base

    def self.configure
      yield self
    end

    def self.cache_directory=(cache_directory)
      @@cache_directory = cache_directory
    end

    def self.cache_directory
      @@cache_directory
    end

  end
end
