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

  FILTER_ATTRIBUTES = [:_id, :prices, :deleted_date, :provider_type, :provider_id, :phone_id]
  def get_hash(options = {})
    offer = catalogue_item.to_hash.with_indifferent_access
    provider = offer[:provider_type].constantize.find(offer[:provider_id]).account
    provider = AccountDecorator.decorate(provider)
    offer[:provider] = provider.get_hash
    
    offer.delete_if { |attr, val| FILTER_ATTRIBUTES.include?(attr.to_sym) }
    
    offer
  end
end