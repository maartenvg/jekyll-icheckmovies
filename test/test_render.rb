require 'icheckmovies'
require 'test/unit'
require 'webmock'
require 'mocha/setup'

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

    # Cache will be on by default, but we don't want to cache
    Jekyll::ICheckMoviesTag.any_instance.stubs(:put_movie_in_cache)
    stub_request(:any, /www.icheckmovies.com.*/).to_return(:body => @body)
    stub_request(:any, /api.themoviedb.org.*/).to_return(:body => @tmdb_result)
  end

  def test_get_movies
    tag = Jekyll::ICheckMoviesTag.new("my_movies", "max: 3, cache: false", [])
    result = tag.render(nil)

    images = result.scan('http://cf2.imgobject.com/t/p/w154/pYiAYDn3ltw9Fq7izODuq7oWYwX.jpg')

    assert_equal 3, images.length, "There aren't enough occurances of the image found"
  end

  def test_full_render
    text = "{% my_movies max: 3, username: qwerty, cache: false %}"
    template = Liquid::Template.parse(text)
    result = template.render

    images = result.scan('http://cf2.imgobject.com/t/p/w154/pYiAYDn3ltw9Fq7izODuq7oWYwX.jpg')
    assert_equal 3, images.length, "There aren't enough occurances of the image found"
  end

  def test_full_render_with_one_argument
    text = "{% my_movies qwerty %}"
    template = Liquid::Template.parse(text)
    result = template.render

    images = result.scan('http://cf2.imgobject.com/t/p/w154/pYiAYDn3ltw9Fq7izODuq7oWYwX.jpg')
    assert_equal 3, images.length, "There aren't enough occurances of the image found"
  end
end
