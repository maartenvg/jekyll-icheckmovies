require 'nokogiri'
require 'open-uri'
require 'date'
require 'liquid'
require 'json'

module Jekyll
  class ICheckMoviesTag < Liquid::Tag
    def initialize(tag_name, max = 4, tokens)
      super
      @max = max.to_i
    end

    def render(context)
      url = 'http://www.icheckmovies.com/movies/checked/?user=maartenvg'
      imdb_ids = get_imdb_ids(url)

      params = {"movies" => []}

      imdb_ids.each do |imdb_id|
        movie = TMDB.get_movie("f7c09b27485ed7f3371edb7c0e144535", imdb_id)
        if movie
          poster_url = TMDB.get_poster_url(movie, :small)
          params["movies"] << {
                                "title" => movie["title"], 
                                "year" => movie["release_date"][0,4], 
                                "poster_url" => poster_url, 
                                "description" => movie["overview"], 
                                "imdb_url" => "http://www.imdb.com/title/#{imdb_id}"
                              }
        end
      end

      html_output(params)
    end

    def get_imdb_ids(url)
      doc = Nokogiri::HTML(open(url))
      movies = doc.css('li.listItemMovie')[0,@max]

      return [] unless movies

      movies.map { |movie| movie.css('.optionIMDB').first.attribute('href').value()[/tt[0-9]+/]}
    end
    
    def html_output(movies)
      template = ""
      File.open(File.expand_path "icheckmovies.html", File.dirname(__FILE__)) do |io|
        template = io.read
      end
      Liquid::Template.parse(template).render(movies)
    end
  end
  
  class TMDB
    POSTER_SIZES = {
      xsmall: "w92",
      small: "w154",
      normal: "w185",
      large: "w342",
      xlarge: "w500"
    }
    
    BASE_URL = "http://cf2.imgobject.com/t/p/"

    def self.get_movie(api_key, id)
      headers  = { 'Accept' => "application/json" }
      response = open("http://api.themoviedb.org/3/movie/#{id}?api_key=#{@api_key}&append_to_response=images", headers)
      JSON.parse(response.read)
    end
    
    def self.get_poster_url(movie, size = :normal)
      image = movie['images']['posters'][0]['file_path']
      
      "#{BASE_URL}#{POSTER_SIZES[size]}#{image}"
    end
  end
  
end

Liquid::Template.register_tag('my_movies', Jekyll::ICheckMoviesTag)
