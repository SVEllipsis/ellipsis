#!/usr/bin/env ruby
require 'rubygems'
require 'hex_string'
require 'sinatra'
require "sinatra/content_for"
require "sinatra/json"

#Reloader
require './lib/sinatra-reloader'


class App < Sinatra::Application
  set :afloat, !!ENV['AFLOAT'] || false

  helpers Sinatra::ContentFor

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

    redirect '/map' unless settings.afloat

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

  get '/map' do
    # Disable if on boat
    return pass if settings.afloat

    @page = {:title => 'Map'}

    @gmaps_api_key = 'AIzaSyCutm8yU9R_oPItTgnNq1GtuP-3tX7h91M'
    @json_params = ''

    @nmea = Nmea.last();
    @weather = Weather.last();

    erb :map
  end

  get '/map.json' do
    #Might want to cache this at some point
    pings = Nmea.all(:order => [:id.asc])
    content_type :json
    pings.to_json
  end

  # Hot pants! It's named capture groups in regexp
  get %r{^/data(?:\.(?<format>json))?$} do
    # These parameters come from the query string
    params[:start] ||= nil
    params[:end] ||= nil
    params[:fields] ||= nil
    params[:resolution] = params[:resolution].to_i || 60
    params[:limit] = params[:limit].to_i || 10
    params[:page] = params[:page].to_i || 1

    fields = (params[:fields] ? params[:fields].split(',') : nil)

    data = get_data({
      :start => (params[:start] ? DateTime.parse(params[:start]) : nil),
      :end =>  (params[:end] ? DateTime.parse(params[:end]) : nil),
      :fields => fields,
      :limit => params[:limit],
      :page => params[:page],
    })

    # Datamapper fields are lazy loaded so they end up being populated anyway if
    # we return data immediately.
    # Make sure that only the requested fields are returned in the dataset by
    # building our own hash.
    if fields
      data = data.map {|item|
        reduced_item = {}
        fields.each {|field|
          reduced_item[field] = item[field]
        }

        reduced_item
      }
    end
    json_string = json({:count => data.length, :data => data})

    # return jsonp if callback parameter is added
    if params[:callback]
      json_string = "#{params[:callback]}(#{(json_string)});"
    end

    json_string
    # TODO setup CORS headers so this can be accessed by anybody
  end

  def get_data(opts={})
    # TODO allow customising order data is returned
    # TODO resolution option for limiting amount of datapoints
    # datapoint every (1min / 5min / 30min) etc
    # http://stackoverflow.com/questions/10403039/mysql-select-query-5-minute-increment

    opts = {
      :start => nil,
      :end => nil,
      :fields => nil,
      :resolution => nil,
      :limit => 0,
      :page => 1,
    }.merge(opts)

    parameters ={
      :order => [ :created_at.desc ]
    }

    parameters[:fields] = opts[:fields] if opts[:fields]
    parameters[:created_at.gt] = opts[:start] if opts[:start]
    parameters[:created_at.lt] = opts[:end] if opts[:end]
    parameters[:limit] = opts[:limit] if opts[:limit] != 0
    parameters[:offset] = (opts[:page] -1) * opts[:limit] if opts[:page] > 1 && opts[:limit] != 0

    Nmea.all(parameters)
  end

  # Messaging
  get '/messages' do

    @page = {:title => 'Messages'}

    @messages = Messages.all(
      :order => [ :created_at.desc ],
      :limit => 50
    )

    erb :messages
  end

  post '/messages' do
    Messages.send_message(params['message'])
    redirect '/messages'
  end

  post '/rockblock' do
    data = params['data'].to_byte_string

    unless data.count(',') == 7
      status 200
      body 'not-nmea'
    end

    metrics = data.split(',')

    unless metrics[0] == '0.0'
      lat = metrics[0]
      long = metrics[1]
    else
      lat = params['iridium_latitude']
      long = params['iridium_longitude']
    end

    Nmea.create(
      :lat => lat,
      :long => long,
      :speed => metrics[3],
      :bearing => metrics[2],
      :created_at => Time.now()
    )

    Weather.create(
      :temp_out => metrics[5],
      :wind_avg => metrics[6],
      :wind_dir => metrics[7],
      :rel_pressure => metrics[8]
    )

    #Tweet.send_nmea

    status 200
    body 'thankyou'

  end

end
