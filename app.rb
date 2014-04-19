#!/usr/bin/env ruby
require 'rubygems'
require 'sinatra'
require 'data_mapper'

configure do
  DataMapper.setup(:default, {
  adapter: 'mysql',
  database: 'ellipsis',
  username: 'root',
  password: '',
  host: 'localhost',
  port: 3306,
  socket: '/opt/boxen/data/mysql/socket'
  })
end


class Event
  include DataMapper::Resource

  property :id, Serial
  property :metric, String
  property :value, String
end

DataMapper.finalize.auto_upgrade!

class App < Sinatra::Application
  get '/' do
    "This is a test message"
  end
end
