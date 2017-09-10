require 'json'
require 'bundler'
Bundler.require(:default)

require './config/environments'
require './lib/word_matcher'

get '/search' do
  headers('Access-Control-Allow-Origin' => '*')
  content_type :json

  matcher = WordMatcher.new(params)
  words = matcher.get_words.pluck(:word)
  { words: words }.to_json
end

