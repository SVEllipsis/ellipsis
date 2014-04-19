#!/usr/bin/env ruby
require 'rubygems'
require 'sinatra'
require "sinatra/json"

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

  # Hot pants! It's named capture groups in regexp
  get %r{^/weather(?:\.(?<format>json))?$} do
    data = {}

    return json data if params[:format] == 'json'
    @page = { :title => params[:format].to_s + 'Weather'}
    erb :weather
  end

  get %r{^/orientation(?:\.(?<format>json))?$} do
    data = {}

    return json data if params[:format] == 'json'
    @page = { :title => 'Orientation' }
    erb :orientation
  end
end
