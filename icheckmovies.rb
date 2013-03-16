require 'nokogiri'   
require 'open-uri'  
require 'ruby-tmdb3'

url = 'http://www.icheckmovies.com/movies/checked/?user=maartenvg'

# setup your API key
Tmdb.api_key = "f7c09b27485ed7f3371edb7c0e144535"

# setup your default language
Tmdb.default_language = "en"


doc = Nokogiri::HTML(open(url))  
  
doc.css('li.listItemMovie')[0,4].each do | movie | 
    name = movie.css('h2 a').first.content()
    imdb = movie.css('.optionIMDB').first.attribute('href').value()
    year = movie.css('.info a').first.content()
    p name
    p imdb
    p year
end 

