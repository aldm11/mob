class CatalogueItem
  include Mongoid::Document
  include Mongoid::Paperclip
  include Tire::Model::Search
  include Tire::Model::Callbacks
  
  field :actual_price, :type => Float
  field :date_from, :type => DateTime
  field :deleted_date, :type => DateTime
  
  embeds_many :prices
  belongs_to :provider, polymorphic: true
  belongs_to :phone
  
  validates :actual_price, :presence => true 
  
  before_save do |ci|
    ci.date_from = Time.new.to_time.to_i
  end
  
  PHONE_ATTRIBUTES_INDEX = ["_id", "brand", "model", "camera", "os", "height", "width", "weight", "display", "internal_memory", "external_memory", "amazon_image_small_full", "amazon_image_medium_full"]
  def phone_to_document(phone_hash)
    document = phone_hash.select { |attribute, value| PHONE_ATTRIBUTES_INDEX.include?(attribute) }
  end
  
  PROVIDER_ATTRIBUTES_INDEX = ["_id", "_type", "avatar", "logo", "name", "address", "phone", "fax", "website"]
  def provider_to_document(provider_hash)
    document = provider_hash.select { |attribute, value| PROVIDER_ATTRIBUTES_INDEX.include?(attribute) }
  end
  
  def to_indexed_json
    document = {}
    document["actual_price"] = self.actual_price
    document["date_from"] = self.date_from
    document["deleted_date"] = self.deleted_date
    document["old_prices"] = self.prices
    document["phone"] = phone_to_document(JSON.parse(self.phone.to_json).with_indifferent_access)
    document["provider"] = provider_to_document(JSON.parse(self.provider.to_json).with_indifferent_access)
    document["provider"]["username"] = self.provider.account.username
    document.to_json
  end
  
  #TODO: change all documents that belong to phone or provider when changing phone or provider - when change phone get all its catalogue items and index itthem
  #TODO: add indexing logic for documents that are not in index (created earlier)
end