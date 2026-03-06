require 'net/http'
require 'json'
require 'fileutils'
require 'zlib'

module ImdbApi
  class ApiClient
    BASE_URL = 'https://api.imdbapi.dev'

    def self.get_title(imdb_id)
      fetch_cached("titles/#{imdb_id}.json.gz") { get("/titles/#{imdb_id}") }
    end

    def self.get_title_credits(imdb_id)
      fetch_cached("titles/#{imdb_id}_credits.json.gz") do
        credits = []
        page_token = nil

        loop do
          path = "/titles/#{imdb_id}/credits?pageSize=50"
          path += "&pageToken=#{page_token}" if page_token

          response = get(path)
          credits.concat(response['credits'] || [])

          page_token = response['nextPageToken']
          break if page_token.nil? || page_token.empty?
        end

        credits
      end
    end

    def self.get_name(imdb_id)
      fetch_cached("names/#{imdb_id}.json.gz") { get("/names/#{imdb_id}") }
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
