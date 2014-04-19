#!/usr/bin/env ruby
require 'rubygems'
require 'sinatra'

configure do
  Dir[File.join(File.dirname(__FILE__), "initializers/*.rb")].each do |file|
    require file
  end
end

class App < Sinatra::Application
  get '/' do
    "Welcome Aboard"
  end
end
