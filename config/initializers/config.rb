CONFIG = YAML.load_file(Rails.root.join('config', 'couchdb.yml'))[Rails.env]
SETTINGS = YAML.load_file(Rails.root.join('config','settings.yml'))
