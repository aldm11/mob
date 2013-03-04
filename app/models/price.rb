class Price
  include Mongoid::Document
  
  field :value, :type => Float
  field :date_from, :type => DateTime
  field :date_to, :type => DateTime
  
  embedded_in :catalogue_item
  
  validates :value, :presence => true
  validates :date_from, :presence => true
  
  before_create do |price|
    price.date_to = Time.new.to_time.to_i
  end
end