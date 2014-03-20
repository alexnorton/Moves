require 'sinatra/base'
require 'json'
require_relative 'model'

class Moves < Sinatra::Base
  set :root, File.dirname(__FILE__)

  ActiveRecord::Base.logger = Logger.new(STDOUT)

  after do
    ActiveRecord::Base.connection.close
  end

  get '/places.json' do
    content_type :json

    return 'User not found' unless user = User.where(id: params['user']).first

    Place.where(user: user).map {|place|
      {
          :type => 'Point',
          :coordinates => [place.long, place.lat],
          :properties => {
              :name => place.name,
              :id => place.id
          }
      }
    }.to_json
  end

  get '/journeys.json' do
    content_type :json

    return 'User not found' unless user = User.where(id: params['user']).first

    total = Journey.where(from_id: params['from']).count

    journeys = Journey.select('from_id, to_id, count(*) as count').where(user: user).group('from_id, to_id').includes(:from, :to)
    journeys = journeys.where(from_id: params['from']) if params['from']

    journeys.map {|journey|
      {
        :type => 'LineString',
        :coordinates => [
            [journey.from.long, journey.from.lat],
            [journey.to.long, journey.to.lat]
        ],
        :properties => {
            :count => journey.count,
            :total => total,
            :from_name => journey.from.name,
            :to_name => journey.to.name
        }
      }
    }.to_json
  end
end