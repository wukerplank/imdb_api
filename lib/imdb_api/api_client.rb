require 'net/http'
require 'json'
require 'fileutils'
require 'zlib'

module ImdbApi
  class ApiClient
    BASE_URL = 'https://api.balloonerismm.workers.dev'

    def self.get_title(imdb_id)
      fetch_cached("movie/#{imdb_id}.json.gz") { get("/movie/#{imdb_id}") }
    end

    def self.get_title_credits(imdb_id)
      fetch_cached("movie/#{imdb_id}_credits.json.gz") { get("/movie/#{imdb_id}/credits") }
    end

    def self.get_name(imdb_id)
      fetch_cached("person/#{imdb_id}.json.gz") { get("/person/#{imdb_id}") }
    end

  private

    def self.fetch_cached(relative_path)
      cache_dir = ImdbApi::Base.cache_directory
      return yield unless cache_dir

      path = File.join(cache_dir, relative_path)

      if File.exist?(path)
        JSON.parse(Zlib::GzipReader.open(path, &:read))
      else
        yield.tap do |data|
          FileUtils.mkdir_p(File.dirname(path))
          Zlib::GzipWriter.open(path) { |gz| gz.write(JSON.generate(data)) }
        end
      end
    end

    def self.get(path)
      uri = URI("#{BASE_URL}#{path}")
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true

      request = Net::HTTP::Get.new(uri)
      request['Accept'] = 'application/json'

      response = http.request(request)
      JSON.parse(response.body)
    end
  end
end
