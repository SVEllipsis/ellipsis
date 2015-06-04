#!/usr/bin/env ruby
require 'rubygems'
require 'hex_string'
require 'sinatra'
require "sinatra/content_for"
require "sinatra/json"

#Reloader
require './lib/sinatra-reloader'


class App < Sinatra::Application

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
    redirect '/map'
  end

  get '/map' do

    @page = {:title => 'Map'}

    @gmaps_api_key = 'AIzaSyCutm8yU9R_oPItTgnNq1GtuP-3tX7h91M'
    @json_params = ''

    @nmea = Nmea.last();
    @weather = Weather.last();

    erb :map
  end

  get '/map.json' do
    # Allow CORS requests from any host
    response['Access-Control-Allow-Origin'] = '*'
    #Might want to cache this at some point
    pings = Nmea.all(:order => [:id.asc])
    content_type :json
    pings.to_json
  end

  # Hot pants! It's named capture groups in regexp
  get %r{^/data(?:\.(?<format>json))?$} do
    # Allow CORS requests from any host
    response['Access-Control-Allow-Origin'] = '*'

    # These parameters come from the query string
    params[:start_time] ||= nil
    params[:end_time] ||= nil
    params[:journey_id] = params[:journey_id].to_i || nil
    params[:fields] ||= nil
    params[:resolution] = params[:resolution].to_i || 60
    params[:limit] = params[:limit].to_i || 10
    params[:page] = params[:page].to_i || 1
    params[:order] = params[:order] || 'id:desc'


    # params.order is an string that looks like: id:desc,created_at:asc
    # which should translate to params[:order] = [:id.desc, created_at.asc]
    # TODO Validate the correct naming for these things
    order = params[:order].split(',').map do |order_tuple|
      pair = order_tuple.split(':')
      pair[0].to_sym.send(pair[1].to_sym)
    end


    fields = (params[:fields] ? params[:fields].split(',') : nil)

    data = get_data({
      :start => (params[:start_time] ? DateTime.parse(params[:start_time]) : nil),
      :end =>  (params[:end_time] ? DateTime.parse(params[:end_time]) : nil),
      :journey_id => params[:journey_id],
      :fields => fields,
      :limit => params[:limit],
      :page => params[:page],
      :order => order,
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
      :start_time => nil,
      :end_time => nil,
      :journey_id => nil,
      :fields => nil,
      :resolution => nil,
      :limit => 0,
      :page => 1,
      :order => [ :created_at.desc ]
    }.merge(opts)

    parameters = {}

    parameters[:fields] = opts[:fields] if opts[:fields]
    parameters[:created_at.gt] = opts[:start_time] if opts[:start_time]
    parameters[:created_at.lt] = opts[:end_time] if opts[:end_time]
    parameters[:journey_id.eql] = opts[:journey_id] if opts[:journey_id]
    parameters[:limit] = opts[:limit] if opts[:limit] != 0
    parameters[:offset] = (opts[:page] -1) * opts[:limit] if opts[:page] > 1 && opts[:limit] != 0
    parameters[:order] = opts[:order] if opts[:order]

    Nmea.all(parameters)
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
      :journey_id => 2,
      :created_at => Time.now()
    )

    #Tweet.send_nmea

    status 200
    body 'thankyou'

  end

end
