module ImdbApi
  class Base

    def self.configure(&block)
      yield self
    end

    def self.cache_directory=(cache_directory)
      @@cache_directory = cache_directory
    end

    def self.cache_directory
      @@cache_directory
    end




    def self.fix_encoding(str)
      return if str.nil? || str.strip==""
      if str.respond_to?(:encode)
        str.encode('UTF-8')
      else
        Iconv.iconv('ISO-8859-1', 'UTF-8', str).first.to_s
      end
    end
  end
end
