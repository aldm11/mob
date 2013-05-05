include DeviseHelper

class Phone
  include Mongoid::Document
  include Mongoid::Paperclip
  include Tire::Model::Search
  
  NUMBER_OF_LATEST_PRICES = 15

  field :brand, :type => String
  field :model, :type => String
  field :created_at, :type => DateTime
  field :last_updated, :type => DateTime
  field :camera, :type => Hash
  field :weight, :type => Float
  field :height, :type => Float
  field :width, :type => Float
  field :os, :type => String
  field :display, :type => String
  field :internal_memory, :type => String
  field :external_memory, :type => String
  field :specifications, :type => Hash
  field :amazon_image_small, :type => String
  field :amazon_image_medium, :type => String
  
  field :latest_prices, :type => Array
  field :latest_prices_size, :type => Integer
  field :latest_price, :type => Hash
  field :average_review, :type => Float
  field :reviews_count, :type => Integer
  field :comments_count, :type => Integer
  
  has_mongoid_attached_file :image
  has_mongoid_attached_file :amazon_image_small_full
  has_mongoid_attached_file :amazon_image_medium_full
  
  validates :brand, :presence => true
  validates :model, :presence => true
  validates :camera, :presence => true
  validates :weight, :presence => true
  validates :height, :presence => true
  validates :os, :presence => true
  validates :display, :presence => true
  
  attr_accessible :brand, :model, :created, :camera, :weight, :height, :width, :internal_memory, :external_memory, :amazon_image_small, :amazon_image_medium, :os, :display, :specifications, :image, :account_id
  
  belongs_to :account
  has_many :comments, as: :context
  embeds_many :reviews
  has_and_belongs_to_many :accounts_following, class_name: 'Account'
  
  has_many :catalogue_items
  
  mapping do
    indexes :brand, type: "multi_field", fields: { 
      analyzed: {type: "string", index: "analyzed"},
      original: {type: "string", index: "not_analyzed"} 
    }
    indexes :model, type: "multi_field", fields: {
      analyzed: {type: "string", index: "analyzed"},
      original: {type: "string", index: "not_analyzed"}       
    }
    indexes :catalogue_items, type: "nested"
  end
  
  before_create do |phone|
    phone.created_at = Time.new.to_time.to_i
    phone.last_updated = phone.created_at
    phone.camera = {:all => phone.camera}
  end

  #TODO: maybe change to before save  
  before_update do |phone|
    phone.last_updated = Time.new.to_time.to_i
    phone.latest_prices_size = phone.latest_prices ? phone.latest_prices.length : 0
  end
  
  def save(options = {})
    set_average_review 
    set_comments_count
    super
    Phone.tire.mapping
    update_index unless options[:without_index]
  end
  
  def set_average_review
    self.reviews_count = self.reviews.length
    self.average_review = self.reviews.empty? ? 0 : self.reviews.map {|review| review.review}.inject{ |sum, rev| sum + rev } / self.reviews.size
  end
  
  def set_comments_count
    self.comments_count = self.comments.count
  end
  
  PHONE_ATTRIBUTES_INDEX = ["_id", "brand", "model", "camera", "os", "height", "width", "weight", "display", "internal_memory", "external_memory", "specifications", "latest_price", "latest_prices_size", "reviews_count", "average_review", "comments_count"]
  def phone_to_document
    document = {}.with_indifferent_access
    self.attributes.each do |attr, value|
      document.merge!(attr.to_s => value) if PHONE_ATTRIBUTES_INDEX.include?(attr.to_s)
    end
    
    if self.amazon_image_small_full
      document.merge!("amazon_image_small_full" => self.amazon_image_small_full.to_s) 
    elsif self.attributes["amazon_image_small"]
      document.merge!("amazon_image_small" => self.amazon_image_small.to_s) 
    end

    if self.amazon_image_medium_full
      document.merge!("amazon_image_medium_full" => self.amazon_image_medium_full.to_s) 
    elsif self.attributes["amazon_image_medium"]
      document.merge!("amazon_image_medium" => self.amazon_image_medium.to_s) 
    end
    document["latest_price"]["catalogue_id"] = document["latest_price"]["catalogue_id"].to_s if document["latest_price"] && document["latest_price"]["catalogue_id"]

    document
  end
  
  PROVIDER_ATTRIBUTES_INDEX = ["_id", "_type", "avatar", "logo", "name", "address", "phone", "fax", "website"]
  def provider_to_document(provider_hash)
    document = provider_hash.select { |attribute, value| PROVIDER_ATTRIBUTES_INDEX.include?(attribute) }
  end
  
  def to_indexed_json
    document = phone_to_document
    document[:catalogue_items] = []
    document[:price] = []
    self.catalogue_items.each do |catalogue_item|
      unless catalogue_item.deleted_date
        prepared_catalogue_item = JSON.parse(catalogue_item.to_json).with_indifferent_access
        prepared_catalogue_item[:provider] = provider_to_document(JSON.parse(catalogue_item.provider.to_json).with_indifferent_access)
        document[:catalogue_items] << prepared_catalogue_item
        
        document[:price] << catalogue_item.actual_price
      end
    end
    document = document.to_json
    document
  end
  
  def overall_review
    count = reviews.empty? ? 0 : reviews.count
    sum = reviews.empty? ? 0 : reviews.sum(:review)
    average = reviews.empty? ? 0 : sum/count
    
    return {:average => average, :count => count}
  end
  
  def name
    [brand, model].join(" ")
  end
  
  INCLUDE_ATTRIBUTES = ["camera", "weight", "width", "height", "camera", "display", "os", "internal memory", "external memory"]
  def attributes_for_display
    attributes = self.attributes.select {|attr, value| INCLUDE_ATTRIBUTES.include?(attr) }
    attributes["camera"] = attributes["camera"]["all"]
    attributes.with_indifferent_access
    return attributes
  end
  
  #TODO: test this function if there are 10 prices when adding new
  def add_price(catalogue_id, price)
    return nil unless catalogue_id && price
    prices = self.latest_prices || []
    prices = prices.delete_if { |prc| prc["catalogue_id"] == catalogue_id }
    prices.delete_at(0) if prices.length == NUMBER_OF_LATEST_PRICES
    price = { "catalogue_id" => catalogue_id, "price" => price, "created_at" => Time.new.to_time.to_i }
    prices << price
    self.latest_prices = prices
    self.latest_price = latest_prices.last
    self.latest_price
  rescue Exception => e
    Rails.logger.fatal "Error while adding price to phones latest prices #{e.message}"
  end
  
  def remove_price(catalogue_id, price)
    return nil unless catalogue_id && price
    prices = latest_prices
    prices = prices.delete_if { |prc| prc["catalogue_id"] == catalogue_id }
    self.latest_prices = prices
    self.latest_price = latest_prices.empty? ? nil : latest_prices.last
    self.latest_price
  rescue Exception => e
    Rails.logger.fatal "Error while adding price to phones latest prices #{e.message}"
  end
  
end