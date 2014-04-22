#!/usr/bin/env ruby
require 'rubygems'
require 'sinatra'
require "sinatra/json"

#Reloader
require './lib/sinatra-reloader'


class App < Sinatra::Application
  set :afloat, !!ENV['AFLOAT'] || false

  configure do
    use Rack::Deflater

    Dir[File.join(File.dirname(__FILE__), "initializers/*.rb")].each do |file|
      require file
    end
  end

  configure :development do
    use Sinatra::Reloader
  end

  get '/?' do
    # These parameters come from the query string
    # TODO Validate user input

    params[:resolution] = params[:resolution].to_i || 60
    params[:limit] = params[:limit].to_i || 10


    @page = {:title => 'Dashboard'}

    @data = get_data({
      :resolution => params[:resolution],
      :limit => params[:limit],
    })

    @limit = params[:limit]
    @resolution = params[:resolution]
    @refreshed_at = DateTime.now

    @partials = [
      :'dashboard/geodata',
      :'dashboard/weather',
    ]

    erb :dashboard
  end

  # Hot pants! It's named capture groups in regexp
  get %r{^/data(?:\.(?<format>json))?$} do
    # These parameters come from the query string
    params[:start] ||= nil
    params[:end] ||= nil
    params[:fields] ||= nil
    params[:resolution] = params[:resolution].to_i || 60
    params[:limit] = params[:limit].to_i || 10

    #TODO Implement page / limit parameters

    # TODO fields are lazy loaded so they end up being populated anyway.
    # Make sure that only the requested fields are returned in the dataset

    data = get_data({
      :start => (params[:start] ? DateTime.parse(params[:start]) : nil),
      :end =>  (params[:end] ? DateTime.parse(params[:end]) : nil),
      :fields => (params[:fields] ? params[:fields].split(',') : nil),
      :limit => params[:limit],
    })

    return json({:count => data.length, :data => data}) if params[:format] == 'json'
    #TODO return jsonp?
  end

  def get_data(opts={})
    # TODO resolution option for limiting amount of datapoints
    # datapoint every (1min / 5min / 30min) etc
    # http://stackoverflow.com/questions/10403039/mysql-select-query-5-minute-increment

    opts = {
      :start => nil,
      :end => nil,
      :fields => nil,
      :resolution => nil,
      :limit => nil,
    }.merge(opts)


    parameters ={
      :order => [ :created_at.desc ]
    }

    parameters[:fields] = opts[:fields] if opts[:fields]
    parameters[:created_at.gt] = opts[:start] if opts[:start]
    parameters[:created_at.lt] = opts[:end] if opts[:end]
    parameters[:limit] = opts[:limit] if opts[:limit]

    Nmea.all(parameters)
  end

end
