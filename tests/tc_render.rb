require "../icheckmovies"
require "test/unit"
require 'webmock'

include WebMock::API
class TestSimpleNumber < Test::Unit::TestCase
  def setup
    @body = <<-BODY
    <ul>
      <li class="listItemMovie">
        <a class="optionIMDB" href="http://www.imdb.com/title/tt0390381/">Title</a>
      </li>
    </ul>
    BODY
    @tmdb_result = <<-TMDB
    {}
    TMDB
  end

  def test_get_movies
    stub_request(:any, /www.icheckmovies.com.*/).to_return(:body => @body)
    stub_request(:any, /api.themoviedb.org.*/).to_return(:body => @tmdb_result)
    
    tag = Jekyll::ICheckMoviesTag.new("my_movies", 3, {})
    result = tag.render(nil)
    
    p result
    
  end
  
  
end
