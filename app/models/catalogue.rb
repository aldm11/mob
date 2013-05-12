class Catalogue
  attr_accessor :full_items
  attr_accessor :catalogue_items
  
  def initialize(account, catalogue_items)
    @catalogue_items = [catalogue_items].flatten
    phones_ids = @catalogue_items.map { |ci| ci.phone.id }
    phones_prices = Managers::CatalogueManager.get_prices_from_others(account, phones_ids)
    @full_items = @catalogue_items.map { |ci| {"catalogue_item" => ci, "prices_from_others" => phones_prices[ci.phone.id] }.with_indifferent_access}
  end
  
end