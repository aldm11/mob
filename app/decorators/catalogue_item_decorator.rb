include ActionView::Helpers::TextHelper

class CatalogueItemDecorator < Draper::Base
  decorates :catalogue_item
  
  def prices_history
    result = if catalogue_item.prices.empty?
      content_tag(:p, "No prices before actual for this item".html_safe, :class => "muted")
    else
      prices = catalogue_item.prices.map { |price| content_tag(:li, price.date_from.strftime('%m/%d/%Y') + " - " + price.date_to.strftime('%m/%d/%Y') + " : " + I18n.t("price", :price => price.value)) }.join
      content_tag(:ul, prices.html_safe, :class => "prices-history-content")
    end
  end

  FILTER_ATTRIBUTES = [:prices, :deleted_date, :provider_type, :provider_id, :phone_id, :tire__matches]
  def get_hash(options = {})
    offer = catalogue_item.to_hash.with_indifferent_access
    offer.delete_if { |attr, val| FILTER_ATTRIBUTES.include?(attr.to_sym) }

    if options[:context].to_s == "catalogue"
      phone_model = catalogue_item.phone
      phone = PhoneDecorator.decorate(catalogue_item.phone)
      offer[:phone] = {
        :id => phone.id,
        :brand => phone.brand,
        :model => phone_model.model, # decorator.model reuturns whole phone model
        :image_path_small => phone.image_path_small,
        :image_path_medium => phone.image_path_medium,
      }
    end
     
    if options[:context].to_s == "phone"    
      provider = catalogue_item.provider_type.constantize.find(catalogue_item.provider_id).account
      provider = AccountDecorator.decorate(provider)
      offer[:provider] = provider.get_hash
    end  
        
    offer
  end
end