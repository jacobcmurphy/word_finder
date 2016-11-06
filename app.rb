require 'sinatra'
require 'sinatra/activerecord'
require './config/environments'
require './models/word'
require './models/pronunciation'
require './models/word_type'
require './models/syllable_count'
require './lib/word_matcher'

get '/' do
  erb :index, layout: 'layouts/main'.to_sym
end

get '/search' do
  words = WordMatcher.new(params)
  erb :search, layout: 'layouts/main'.to_sym, locals: {words: words}
end
