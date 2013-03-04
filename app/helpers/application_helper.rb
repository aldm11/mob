module ApplicationHelper
  def devise_mapping
    Devise.mappings[:account]
  end
end
