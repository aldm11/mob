require "../lib/importers/database/phone_importer.rb"
require "../lib/data_store/memory/phone_details.rb"
require "json"

include Importers::Database::PhoneImporter
include DataStore::Memory::PhoneDetails
include JSON

brand = ARGV[0]
import_phones_from_json(:brand => brand)
