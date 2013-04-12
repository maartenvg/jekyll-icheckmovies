jekyll-icheckmovies
===================

Plugin for Jekyll/Liquid to generate a list of your last checked movies on iCheckMovies. It uses images & information from
The MovieDB via their API and displays it on your website.

Usage
-----
First, make sure that you made your list of checked movies public in your profile.
Go to [the settings page](https://www.icheckmovies.com/settings/privacy/) and set *Movie checks* to _public_.

Simple usage (shows 4 movies): `{% my_movies your_username %}`

Extended usage: `{% my_movie max: 10, username: myname, ... %}`

Available options:
* `max: 5`: The number of movies that you want to show. _(default: 4)_
* `username: ...`: Your username at iCheckMovies.com. (required when using extended options)
* `cache: true|false`: Use caching of TMDB calls, preventing repeated web calls for previously retrieved movies. _(default: true)_
* `size: xsmall|small|normal|large|xlarge`: The size of the movie-posters to be used. _(default: normal)_
* `tmdb_api_key: ...`: Your TMDB api key if you are not not using the default one.