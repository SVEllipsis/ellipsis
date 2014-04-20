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
    params[:start_time] ||= nil
    params[:end_time] ||= nil
    params[:resolution] ||= nil

    @page = {:title => 'Dashboard'}

    # Commented out duration as we're currently working on with demo data
    @data = get_data({
      # start_time => start_time || Time.now - 60*60*3 # Three hours ago
      # end_time = end_time || Time.now
    })

    @data_latest = @data[1]

    @partials = [
      :'dashboard/geodata',
      :'dashboard/weather',
    ]

    erb :dashboard
  end

  # Hot pants! It's named capture groups in regexp
  get %r{^/data(?:\.(?<format>json))?$} do
    # These parameters come from the query string
    params[:start_time] ||= nil
    params[:end_time] ||= nil
    params[:fields] ||= nil
    params[:resolution] ||= nil

    #TODO Implement page / limit parameters

    # TODO fields are lazy loaded so they end up being populated anyway.
    # Make sure that only the requested fields are returned in the dataset

    data = get_data({
      :start_time => (params[:start_time] ? Time.parse(params[:start_time]) : nil),
      :end_time =>  (params[:end_time] ? Time.parse(params[:end_time]) : nil),
      :fields => (params[:fields] ? params[:fields].split(',') : nil),
    })

    return json({:count => data.length, :data => data}) if params[:format] == 'json'
    #TODO return jsonp?
  end

  def get_data(opts={})
    # TODO resolution option for limiting amount of datapoints
    # datapoint every (1min / 5min / 30min) etc
    # http://stackoverflow.com/questions/10403039/mysql-select-query-5-minute-increment

    opts = {
      :start_time => nil,
      :end_time => nil,
      :fields => nil,
      :resolution => nil,
    }.merge(opts)


    parameters ={
      :order => [ :created_at.desc ]
    }

    parameters[:fields] = opts[:fields] if opts[:fields]
    parameters[:created_at.gt] = opts[:start_time] if opts[:start_time]
    parameters[:created_at.lt] = opts[:end_time] if opts[:end_time]

    Nmea.all(parameters)
  end

end
