env = ENV["RACK_ENV"] || "development"

DataMapper.setup(:default, ENV['DATABASE_URL'] || "postgres://localhost/chitter_api_#{env}")

require './lib/user'
require './lib/peep'

DataMapper.finalize

DataMapper.auto_upgrade!