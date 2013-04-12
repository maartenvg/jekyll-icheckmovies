require "icheckmovies"
require "test/unit"
require "mocha/setup"

class TestCache < Test::Unit::TestCase
  def   setup
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
    Jekyll::ICheckMoviesTag.any_instance.stubs(:get_imdb_ids).returns(['tt123456'])
    Jekyll::TMDB.stubs(:get_movie).returns(@tmdb_result)
  end

  def test_write_to_cache_is_called
    text = "{% my_movies max: 1, username: qwerty %}"
    template = Liquid::Template.parse(text)

    Jekyll::ICheckMoviesTag.any_instance.expects(:put_movie_in_cache).with('tt123456', @tmdb_result)

    result = template.render
  end

  def test_right_cache_is_opened
    text = "{% my_movies max: 1, username: qwerty %}"
    template = Liquid::Template.parse(text)
    cache_path = File.expand_path(File.join(File.dirname(__FILE__), '../.icheckmovie-cache/'))

    Dir.expects(:exists?).with(cache_path).returns(false)
    Dir.expects(:mkdir).with(cache_path)

    filename = File.join(cache_path, "tt123456.cache")
    File.expects(:open).with(filename, 'w')

    result = template.render
  end

  def test_reading_from_cache
    text = "{% my_movies max: 1, username: qwerty %}"
    template = Liquid::Template.parse(text)
    cache_path = File.expand_path(File.join(File.dirname(__FILE__), '../.icheckmovie-cache/'))
    filename = File.join(cache_path, "tt123456.cache")

    File.expects(:exists?).with(filename).returns(true)
    file = mock('file')
    Jekyll::ICheckMoviesTag.any_instance.expects(:open).with(filename).returns(file)
    file.stubs(:read).returns(@tmdb_result)

    result = template.render

    images = result.scan('http://cf2.imgobject.com/t/p/w154/pYiAYDn3ltw9Fq7izODuq7oWYwX.jpg')
    assert_equal 1, images.length, "There aren't enough occurances of the image found"
  end
end