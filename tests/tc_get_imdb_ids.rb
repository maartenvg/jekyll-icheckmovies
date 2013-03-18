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
      <li class="listItemMovie">
        <a class="optionIMDB" href="http://www.imdb.com/title/tt0390382/">Title</a>
      </li>
      <li class="listItemMovie">
        <a class="optionIMDB" href="http://www.imdb.com/title/tt0390383/">Title</a>
      </li>
      <li class="listItemMovie">
        <a class="optionIMDB" href="http://www.imdb.com/title/tt0390384/">Title</a>
      </li>
    </ul>
    BODY
  end

  def test_get_movies
    tag = Jekyll::ICheckMoviesTag.new("my_movies", 3, {})
    stub_request(:any, 'www.example.com').to_return(:body => @body)
    result = tag.get_imdb_ids('http://www.example.com')
    
    assert_equal(3, result.length)
    assert_equal('tt0390381', result[0])
    assert_equal('tt0390382', result[1])
    assert_equal('tt0390383', result[2])
  end
  
  def test_get_more_movies_than_available
    tag = Jekyll::ICheckMoviesTag.new("my_movies", 5, {})
    stub_request(:any, 'www.example.com').to_return(:body => @body)
    result = tag.get_imdb_ids('http://www.example.com')
    
    assert_equal(4, result.length)
    assert_equal('tt0390381', result[0])
    assert_equal('tt0390382', result[1])
    assert_equal('tt0390383', result[2])
    assert_equal('tt0390384', result[3])
  end
  
  def test_get_zero_movies
    tag = Jekyll::ICheckMoviesTag.new("my_movies", 0, {})
    stub_request(:any, 'www.example.com').to_return(:body => @body)
    result = tag.get_imdb_ids('http://www.example.com')
    
    assert_equal([], result)
  end
  
  def test_no_movies_available
    tag = Jekyll::ICheckMoviesTag.new("my_movies", 3, {})
    stub_request(:any, 'www.example.com').to_return(:body => "")
    result = tag.get_imdb_ids('http://www.example.com')
    
    assert_equal([], result)
  end
end