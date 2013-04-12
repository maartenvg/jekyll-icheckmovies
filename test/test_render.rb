require "icheckmovies"
require "test/unit"
require 'webmock'

include WebMock::API
class TestRender < Test::Unit::TestCase
  def setup
    @body = <<-BODY
    <ul>
      <li class="listItemMovie">
        <a class="optionIMDB" href="http://www.imdb.com/title/tt0390381/">Title</a>
      </li>
      <li class="listItemMovie">
        <a class="optionIMDB" href="http://www.imdb.com/title/tt0390382/">Title</a>
      </li>
      <li class="listItemMovie">
        <a class="optionIMDB" href="http://www.imdb.com/title/tt0390383/">Title</a>
      </li>
    </ul>
    BODY
    @tmdb_result = <<-TMDB
    {
      "title": "title",
      "release_date": "2010-02-21",
      "overview": "It is a nice movie about stuff",
      "images": {
        "backdrops": [],
        "posters": [
          {
            "file_path": "/pYiAYDn3ltw9Fq7izODuq7oWYwX.jpg"
          }
        ]
      }
    }
    TMDB
  end

  def test_get_movies
    stub_request(:any, /www.icheckmovies.com.*/).to_return(:body => @body)
    stub_request(:any, /api.themoviedb.org.*/).to_return(:body => @tmdb_result)
    
    tag = Jekyll::ICheckMoviesTag.new("my_movies", "max: 3", [])
    result = tag.render(nil)
    
    images = result.scan('http://cf2.imgobject.com/t/p/w154/pYiAYDn3ltw9Fq7izODuq7oWYwX.jpg')
    
    assert_equal 3, images.length, "There aren't occurances of the image found"
  end
end
