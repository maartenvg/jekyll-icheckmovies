require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'ruby-tmdb3'
require 'date'
require 'liquid'

module Jekyll
  class ICheckMoviesTag < Liquid::Tag
    def initialize(tag_name, max = 4, tokens)
      super
      Tmdb.api_key = "f7c09b27485ed7f3371edb7c0e144535"
      Tmdb.default_language = "en"
      
      @max = max.to_i
    end

    def render(context)
      url = 'http://www.icheckmovies.com/movies/checked/?user=maartenvg'
      imdb_ids = get_imdb_ids(url)
      
      posters = []
      
      imdb_ids.each do |imdb_id|
        tmdb = TmdbMovie.find(:imdb => imdb_id, :limit => 1, :expand_results => false)
        posters << "<img src=\"#{tmdb.posters[0].sizes.w185.url}\" />"  
      end
     
      posters.join("<br />\n")
    end
    
    def get_imdb_ids(url)
      imdb_ids = 
      doc = Nokogiri::HTML(open(url))
      movies = doc.css('li.listItemMovie')[0,@max]
      
      return [] unless movies
      
      movies.collect { |movie| movie.css('.optionIMDB').first.attribute('href').value()[/tt[0-9]+/]}
    end
  end
end

Liquid::Template.register_tag('my_movies', Jekyll::ICheckMoviesTag)
