class CatalogueItem
  include Mongoid::Document
  include Mongoid::Paperclip
  
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
end