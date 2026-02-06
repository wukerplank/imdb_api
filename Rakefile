require "bundler/gem_tasks"
require "imdb_api"
require "mechanize"

desc "Fetch movie"
task :fetch_movie => :configure do
    pp ImdbApi::Movie.find(ARGV[1])
end

desc "Fetch person"
task :fetch_person => :configure do
    pp ImdbApi::Person.find(ARGV[1])
end

task :configure do
    FileUtils.mkdir_p("/tmp/imdb_api/movies/info/")
    FileUtils.mkdir_p("/tmp/imdb_api/movies/cast/")
    FileUtils.mkdir_p("/tmp/imdb_api/people/")
    ImdbApi::Base.configure do |config|
        config.cache_directory = "/tmp/imdb_api"
    end
end