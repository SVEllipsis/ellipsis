#!/usr/bin/env ruby
require 'rubygems'
require 'sinatra'

#Reloader
require './lib/sinatra-reloader'


class App < Sinatra::Application
  configure do
    Dir[File.join(File.dirname(__FILE__), "initializers/*.rb")].each do |file|
      require file
    end
  end

  configure :development do
    use Sinatra::Reloader
  end

  get '/?' do
    redirect '/weather'
  end

  get '/weather' do
    @page = { :title => 'Weather'}

    erb :weather
  end

    get '/orientation' do
    @page = { :title => 'Orientation'}

    erb :orientation
  end
end
