require "icheckmovies"
require "test/unit"

class TestParams < Test::Unit::TestCase
  def test_illegal_param
    assert_raise ArgumentError do
      tag = Jekyll::ICheckMoviesTag.new("my_movies", "DOES_NOT_EXIST: 3", {})
    end
  end
  
  def test_multiple_params
    tag = Jekyll::ICheckMoviesTag.new("my_movies", "max: 3, username: user, size: xlarge", {})
    
    assert_equal 3, tag.params[:max]
    assert_equal 'user', tag.params[:username]
    assert_equal :xlarge, tag.params[:size]
  end
  
  def test_only_username
    tag = Jekyll::ICheckMoviesTag.new("my_movies", "user", {})
    
    assert_equal 4, tag.params[:max]
    assert_equal 'user', tag.params[:username]
  end
  
  def test_boolean_param_false
    tag = Jekyll::ICheckMoviesTag.new("my_movies", "cache: false", {})
    
    assert_equal false, tag.params[:cache]
  end
  
  def test_boolean_param_false
    tag = Jekyll::ICheckMoviesTag.new("my_movies", "cache: true", {})
    
    assert_equal true, tag.params[:cache]
  end
end