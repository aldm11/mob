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
end