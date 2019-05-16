# Load the Rails application.
require File.expand_path('../application', __FILE__)

# Initialize the Rails application.
Rails.application.initialize!
require "bantu_soundex"
require "csv"
require "simple_elastic_search"
require "levenshtein"
require "zebra_printer"


class Pusher <  CouchRest::Model::Base
  configs = YAML.load_file("#{Rails.root}/config/couchdb.yml")[Rails.env]
  connection.update({
                        :protocol => "#{configs['protocol']}",
                        :host     => "#{configs['host']}",
                        :port     => "#{configs['port']}",
                        :prefix   => "#{configs['prefix']}",
                        :suffix   => "#{configs['suffix']}",
                        :join     => '_',
                        :username => "#{configs['username']}",
                        :password => "#{configs['password']}"
                    })
end