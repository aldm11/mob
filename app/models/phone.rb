include DeviseHelper

class Phone
  include Mongoid::Document
  include Mongoid::Paperclip
  include Tire::Model::Search
  
  NUMBER_OF_LATEST_PRICES = 15

  field :brand, :type => String, :multifield => true
  field :model, :type => String, :multifield => true
  field :created_at, :type => DateTime
  field :last_updated, :type => DateTime
  field :camera, :type => Hash, :subfields => {
    :mpixels => {:type => "double"}, 
    :video => {:type => "boolean"}, 
    :front => {:type => "boolean"}, 
    :blic => {:type => "boolean"}, 
    :resolution => {}
  }
  field :weight, :type => Float
  field :height, :type => Float
  field :width, :type => Float
  field :os, :type => String, :multifield => true
  field :display, :type => Hash
  field :internal_memory, :type => Float
  field :external_memory, :type => Float
  field :specifications, :type => Hash
  field :amazon_image_small, :type => String
  field :amazon_image_medium, :type => String
  field :battery, :type => Hash
  field :date_manufectured, :type => DateTime
 
  field :latest_prices, :type => Array
  field :latest_prices_size, :type => Integer
  field :latest_price, :type => Hash
  
  field :like_count, :type => Integer
  field :unlike_count, :type => Integer
  
  field :comments_count, :type => Integer
  field :deleted, :type => Boolean, :default => false
  
  has_mongoid_attached_file :image
  has_mongoid_attached_file :amazon_image_small_full
  has_mongoid_attached_file :amazon_image_medium_full
  
  validates :brand, :presence => true
  validates :model, :presence => true
  validates :os, :presence => true
  
  attr_accessible :brand, :model, :created, :camera, :weight, :height, :width, :internal_memory, :external_memory, :amazon_image_small, :amazon_image_medium, :os, :display, :specifications, :image, :account_id
  
  belongs_to :account
  has_many :comments, as: :context
  embeds_many :reviews
  has_and_belongs_to_many :accounts_following, class_name: 'Account'
  
  has_many :catalogue_items
  
  ### ES settings
  settings  :number_of_shards => 1,
            :number_of_replicas => 1,
            :refresh_interval => -1,
            :analysis => {
              :analyzer => {
                :ngram => {
                  "type" => "custom",
                  "tokenizer" => "ngram",
                  "filter" => ["lowercase", "standard"]
                  
                }
              },
              :tokenizer => {
                :ngram => {
                  "min_gram" => 3,
                  "max_gram" => 8,
                  "type" => "nGram",
                  "token_chars" => ["letter", "digit", "whitespace"]
                }
              }
            } do
  
    mapping do
      multifield_fields = self.fields.select { |fld, details| details.options[:multifield] }.keys.map {|field| field.to_sym}
      multifield_fields.each do |field|
        indexes field, type: "multi_field", fields: { 
          ngram_analyzed: {type: "string", index: "analyzed", analyzer: "ngram"},
          analyzed: {type: "string", index: "analyzed", analyzer: "standard"},
          original: {type: "string", index: "not_analyzed"} 
        }
      end

      indexes :catalogue_items, type: "nested"
      indexes :deleted, type: "boolean"
    end
  end
  
  before_create do |phone|
    phone.created_at = Time.new.to_time.to_i
    phone.last_updated = phone.created_at
  end

  #TODO: maybe change to before save  
  before_update do |phone|
    phone.last_updated = Time.new.to_time.to_i
    phone.latest_prices_size = phone.latest_prices ? phone.latest_prices.length : 0
  end
  
  before_save do |phone|
    phone.camera["mpixels"] = phone.camera["mpixels"].to_f if phone.camera && phone.camera["mpixels"]
    phone.camera["blic"] = phone.camera["blic"].to_s == "1" || phone.camera["blic"].to_s == "true" ? true : false if phone.camera && phone.camera["blic"]
    phone.camera["video"] = phone.camera["video"].to_s == "1" || phone.camera["video"].to_s == "true" ? true : false if phone.camera && phone.camera["video"]
    phone.camera["front"] = phone.camera["front"].to_s == "1" || phone.camera["front"].to_s == "true" ? true : false if phone.camera && phone.camera["front"]
    phone.camera["resolution"] = phone.camera["resolution"] if  phone.camera && phone.camera["resolution"]
   
    phone.width = phone.width.gsub(",", ".").to_f if phone.width && phone.width.is_a?(String)
    phone.height = phone.height.gsub(",", ".").to_f if phone.height && phone.height.is_a?(String)
    phone.weight = phone.weight.gsub(",", ".").to_f if phone.weight && phone.weight.is_a?(String)
    phone.internal_memory = phone.internal_memory.gsub(",", ".").to_f if phone.internal_memory && phone.internal_memory.is_a?(String)
    phone.external_memory = phone.external_memory.gsub(",", ".").to_f if phone.external_memory && phone.external_memory.is_a?(String)
    
    phone.os = "Java" if phone.os.blank?

    phone.reviews = []
    phone.last_updated = Time.new.to_time.to_i
    phone.latest_prices_size = phone.latest_prices ? phone.latest_prices.length : 0
  end
  
  def save(options = {})
    sum_reviews
    
    set_comments_count
    set_latest_prices
    
    opts = options.with_indifferent_access.has_key?("validate") ? {:validate => options[:validate]} : {}
    super(opts)
    
    Phone.tire.mapping
    update_index unless options[:without_index]
    index.refresh
  end
  
  def self.reindex_all(opts = {})
    index = Tire::Index.new("phones")
    index.delete
    Phone.create_elasticsearch_index
    index = Tire::Index.new("phones")
    phones_to_import = Phone.where(:latest_prices.exists => true, :latest_prices.ne => [])
    puts "Importing #{phones_to_import.length.inspect} phones to index"
    #index.import(phones_to_import)
    
    phones_to_import.each { |phone| phone.save }
    
    index.refresh
  end
  
  def sum_reviews
    reviews_by_type = reviews.partition { |review| review.like }
    self.like_count, self.unlike_count = reviews_by_type.first.length, reviews_by_type.last.length    
  end
  
  def set_comments_count
    self.comments_count = self.comments.count
  end
  
  PHONE_ATTRIBUTES_INDEX = ["_id", "brand", "model", "camera", "os", "height", "width", "weight", "display", 
    "internal_memory", "external_memory", "specifications", "latest_price", "latest_prices_size", 
    "like_count", "unlike_count", "comments_count", "deleted"]
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
    
    if self.image.exists?
      document.merge!("image" => self.image.to_s)
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
  
  # def overall_review
    # count = reviews.empty? ? 0 : reviews.count
    # sum = reviews.empty? ? 0 : reviews.sum(:review)
    # average = reviews.empty? ? 0 : sum/count
#     
    # return {:average => average, :count => count}
  # end
  
  def name
    [brand, model].join(" ")
  end
  
  INCLUDE_ATTRIBUTES = ["camera", "weight", "width", "height", "camera", "display", "os", "internal memory", "external memory"]
  def attributes_for_display
    attributes = self.attributes.select {|attr, value| INCLUDE_ATTRIBUTES.include?(attr) }
    attributes["camera"] = if attributes["camera"] && attributes["camera"]["mpixels"]
      camera_display = attributes["camera"]["mpixels"]
      
      self.class.fields["camera"].options[:subfields].each do |attr, details|
        if details[:type].to_s == "boolean" && !attributes["camera"][attr.to_s].nil?
          attr_label = I18n.t(["mongoid.attributes.phone.camera", attr.to_s].join("."))
          attr_value = attributes["camera"][attr.to_s] ? "&#10004;" : "&#10007;"
          camera_display = "#{camera_display}<br/>#{attr_label} : #{attr_value}"
        end
      end
      camera_display
    else
      "-"
    end
    attributes.with_indifferent_access
    return attributes
  end
  
  def set_latest_prices
    active_catalogue_items = self.catalogue_items.select { |ci| ci.deleted_date.nil? }
    if active_catalogue_items.empty?
      self.latest_prices = []
      self.latest_price = {}
    else
      from = active_catalogue_items.length >= NUMBER_OF_LATEST_PRICES ? active_catalogue_items.length - NUMBER_OF_LATEST_PRICES : 0
      to = active_catalogue_items.length - 1
      
      active_catalogue_items[from..to].each do |ci| 
        add_price(ci.id, ci.actual_price, ci.date_from.to_time.to_i)
      end
     
      self.latest_prices_size = self.latest_prices.length
      self.latest_price = self.latest_prices.last
    end
  end
  
  #TODO: test this function if there are 10 prices when adding new
  def add_price(catalogue_id, price, timestamp)
    return nil unless catalogue_id && price
    prices = self.latest_prices || []
    prices = prices.delete_if { |prc| prc["catalogue_id"] == catalogue_id }
    prices.delete_at(0) if prices.length == NUMBER_OF_LATEST_PRICES
    price = { "catalogue_id" => catalogue_id, "price" => price, "created_at" => timestamp }
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