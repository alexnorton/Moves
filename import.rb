require 'json'
require_relative 'model'

data = JSON.parse(File.read('data/timothy.json'))

user = User.where(name: 'Timothy').first_or_create
user.places.destroy_all
user.journeys.destroy_all

journeys = []

data['export'].each do |date|
  if date['segments'] then date['segments'].each do |segment|
    if segment['type'] == 'place'

      place = Place.where(moves_id: segment['place']['id'], user: user).first

      unless place
        place = Place.create(lat: segment['place']['location']['lat'], long: segment['place']['location']['lon'], name: segment['place']['name'], user: user, moves_id: segment['place']['id'])
      end

      if journeys.last
        journeys.last.to = place
        journeys.last.to_time = DateTime.parse(segment['startTime'])
        journeys.last.save
      end

      date = segment['endTime'] ? DateTime.parse(segment['endTime']) : nil

      journeys.push(Journey.new(from: place, from_time: date, user: user))
    end
  end
  end
end