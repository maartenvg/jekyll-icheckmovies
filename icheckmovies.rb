require 'nokogiri'
require 'open-uri'
require 'date'
require 'liquid'
require 'json'

module Jekyll
  class ICheckMoviesTag < Liquid::Tag
    attr_reader :params

    ALLOWED_PARAMS = {max: :int, username: :string, tmdb_api_key: :string, size: :symbol, cache: :bool}
    CACHE_PATH = File.expand_path(File.join(File.dirname(__FILE__), '.icheckmovie-cache/'))


    def initialize(tag_name, params, tokens)
      super

      @params = {
          max: 4,
          tmdb_api_key: 'f7c09b27485ed7f3371edb7c0e144535',
          size: :normal,
          cache: true
      }

      if params.include? ':'
        parse_params(params)
      else
        @params[:username] = params
      end
    end

    def render(context)
      url = "http://www.icheckmovies.com/movies/checked/?user=#{@params[:username]}"
      imdb_ids = get_imdb_ids(url)

      output_params = {"movies" => []}

      imdb_ids.each do |imdb_id|
        movie = get_movie(imdb_id)

        if movie
          poster_url = TMDB.get_poster_url(movie, :small)
          output_params["movies"] << {
                                "title" => movie["title"],
                                "year" => movie["release_date"][0,4],
                                "poster_url" => poster_url,
                                "description" => movie["overview"],
                                "imdb_url" => "http://www.imdb.com/title/#{imdb_id}"
                              }
        end
      end

      html_output(output_params)
    end

    def get_imdb_ids(url)
      doc = Nokogiri::HTML(open(url))
      movies = doc.css('li.listItemMovie')[0, @params[:max]]

      return [] unless movies

      movies.map { |movie| movie.css('.optionIMDB').first.attribute('href').value()[/tt[0-9]+/]}
    end

    private
      def parse_params(params)
        params.split(',').each do |param|
          var, value = param.split(':')

          var = var.strip.to_sym
          value.strip!

          raise ArgumentError.new "Illegal parameter #{var}" unless ALLOWED_PARAMS[var]

          case ALLOWED_PARAMS[var]
          when :int
            value = value.to_i
          when :symbol
            value = value.to_sym
          when :bool
            value = value == 'true'
          end

          @params[var] = value
        end
      end

      def get_movie(imdb_id)
        if @params[:cache] && movie_in_cache(imdb_id)
          get_movie_from_cache(imdb_id)
        else
          result = TMDB.get_movie(@params[:tmdb_api_key], imdb_id)

          put_movie_in_cache(imdb_id, result) if @params[:cache]

          result
        end
      end

      def movie_in_cache(imdb_id)
        File.exists? cache_filename(imdb_id)
      end

      def get_movie_from_cache(imdb_id)
        file = cache_filename(imdb_id)
        JSON.parse(open(file).read)
      end

      def put_movie_in_cache(imdb_id, data)
        Dir.mkdir CACHE_PATH unless Dir.exists? CACHE_PATH

        file = cache_filename(imdb_id)

        File.open(file, 'w') { |f| f.write(data) }
      end

      def cache_filename(imdb_id)
        File.join(CACHE_PATH, "#{imdb_id}.cache")
      end

      def html_output(movies)
        template = ""
        File.open(File.expand_path "icheckmovies.html", File.dirname(__FILE__)) do |io|
          template = io.read
        end
        Liquid::Template.parse(template).render(movies)
      end
    # END PRIVATE
  end

  class TMDB
    POSTER_SIZES = {
      xsmall: "w92",
      small:  "w154",
      normal: "w185",
      large:  "w342",
      xlarge: "w500"
    }

    BASE_URL = "http://cf2.imgobject.com/t/p/"

    def self.get_movie(api_key, id)
      headers  = { 'Accept' => "application/json" }
      response = open("http://api.themoviedb.org/3/movie/#{id}?api_key=#{api_key}&append_to_response=images", headers)
      JSON.parse(response.read)
    end

    def self.get_poster_url(movie, size = :normal)
      image = movie['images']['posters'][0]['file_path']

      "#{BASE_URL}#{POSTER_SIZES[size]}#{image}"
    end
  end

end

Liquid::Template.register_tag('my_movies', Jekyll::ICheckMoviesTag)
