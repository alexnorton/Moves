require 'active_record'
require 'mysql2'

ActiveRecord::Base.establish_connection(
    :adapter => 'mysql2',
    :host => '127.0.0.1',
    :username => 'root',
    :password => '',
    :database => 'moves'
)

class User < ActiveRecord::Base
  has_many :places
  has_many :journeys
end

class Place < ActiveRecord::Base
  belongs_to :user
end

class Journey < ActiveRecord::Base
  belongs_to :from, class_name: "Place"
  belongs_to :to, class_name: "Place"
  belongs_to :user
end