module Managers
  module CatalogueManager
    
    #TODO: add logic for all parameters on modules to call before action to sanitize parameters
    #TODO: change time zone (+1 h)
    def self.add_phone(account, phone, price)
      return {:status => false, :message => "Data not provided", :catalogue_item => nil} if phone.blank? || account.blank? || price.blank?
      
      if phone.is_a?(String)
        brand, model = phone.split(" ", 2) #TODO: this may be bug in some cases
        phones = Phone.where(brand: brand, model: model).to_a      
        return {:status => false, :message => "Phone does not exists", :catalogue_item => nil} if phones.empty? || phones.length != 1

        phone = phones.first
      end
      provider = account.rolable
      result = {}
      
      catalogue_items = CatalogueItem.where(phone_id: phone.id, provider_id: provider.id, deleted_date: nil)
      if catalogue_items.empty?
        result = add_to_catalogue(provider, phone, price)
        catalogue_item = result[:catalogue_item]
      else
        catalogue_item = catalogue_items.to_a.first
        result = set_price(catalogue_item, price)
      end
      
      if result[:status]
        phone = catalogue_item.phone
        phone.add_price(catalogue_item.id, catalogue_item.actual_price)
        phone.save
      end
      Rails.logger.info("Phone added to catalogue")
      return result

    end
    
    #TODO: see why adding price same as actual price doesnt work correct
    def self.add_to_catalogue(provider, phone, price)
      catalogue_item = phone.catalogue_items.build({:actual_price => price, :provider => provider})
      result = {:catalogue_item => catalogue_item}
      if catalogue_item.save
        result.merge!({:status => true, :message => "Phone #{phone.name} added to your catalogue"})
      else
        errors = catalogue_item.errors.full_messages.join(" ")
        result.merge!({:status => false, :message => errors })        
      end
      return result
    rescue Exception => e
      Rails.logger.fatal "Error while deleting phone #{phone.inspect} to catalogue #{account.inspect} : #{e.message} #{e.backtrace}"
      result.merge!({:status => false, :message => "Error while adding phone #{phone.name} to your catalogue"})
    end
    
    def self.set_price(catalogue_item, new_price)
      result = {}
      old_price = catalogue_item.actual_price
      return {:status => false, :catalogue_item => catalogue_item, :message => "You entered same price as actual"} if old_price == new_price

      old_date_from = catalogue_item.date_from
      catalogue_item.prices.push(Price.new({:value =>  old_price, :date_from => old_date_from, :date_to => Time.new.to_time.to_i}))
      catalogue_item.actual_price = new_price
      catalogue_item.save
      result = {:status => true, :catalogue_item => catalogue_item, :message => "Price for phone #{catalogue_item.phone.name} changed"}
      return result
    rescue Exception => e
      Rails.logger.fatal "Error while adding phone #{catalogue_item.phone.inspect} to catalogue: #{e.message} #{e.backtrace}"
      result = {:status => false, :catalogue_item => catalogue_item, :message => "Error while changing price for phone : #{e.inspect}"}
    end
    
    def self.remove_phone(account, phone)
      return {:status => false, :message => "Data not provided"} if account.blank? || phone.blank?
      phone = Phone.find(phone) if phone.is_a?(String)
      provider = account.rolable
      catalogue_items = CatalogueItem.where(phone_id: phone.id, provider_id: provider.id, deleted_date: nil).to_a
      if catalogue_items.empty?
        return {:status => false, :catalogue_item => nil, :message => "Phone does not exists in catalogue"}
      else
        catalogue_item = catalogue_items.first
        catalogue_item.update_attributes(deleted_date: Time.new.to_time.to_i)
        
        result = {:catalogue_item => catalogue_item}
        if catalogue_item.save
          phone = catalogue_item.phone
          phone.remove_price(catalogue_item.id, catalogue_item.actual_price)
          phone.save
          result.merge!(:status => true, :message => "Phone deleted from you catalogue")
          Rails.logger.info "Phone #{phone.inspect} deleted from catalogue #{account.inspect}"
        else
          errors = catalogue_item.errors.full_messages.join(" ")
          result.merge!(:status => false, :message => "Errors while deleting phone from your catalogue #{errors}")
        end
        return result
      end
      rescue Exception => e
        Rails.logger.fatal "Error while deleting phone #{phone.inspect} from catalogue #{account.inspect} : #{e.message} #{e.backtrace}"
        result.merge!(:status => false, :message => "Error while deleting phone")
    end
    
    #can send username of account model as param
    def self.get_catalogue(account)
      return nil if account.blank?
      if account.is_a?(String)
        accounts = Account.where(username: account)
        return nil if accounts.empty? 
        account = accounts.first
      end

      provider = account.rolable
      catalogue_items = CatalogueItem.where(provider_id: provider.id, deleted_date: nil).desc(:date_from).to_a
      rescue Exception => e
        Rails.logger.fatal "Error while getting catalogue for account #{account.inspect} : #{e.message}"
        return nil
    end
    
    #support for passing phone as one or array of ids or of phones
    def self.get_prices_from_others(account, phones, number_of_prices = 4)
      return nil if account.blank? || phones.blank? || number_of_prices == 0
      provider = account.rolable
      phones = [phones].flatten
      phones_ids = phones.map { |phone| phone.is_a?(Phone) ? phone.id.to_s : phone }
      
      catalogue_items = Phone.asc.in(_id: phones_ids).to_a
      catalogue_items = catalogue_items.map { |phone| [phone.id, phone.catalogue_items.select {|ci| ci.deleted_date.nil? && ci.provider.id != provider.id }.map { |ci| {"provider_id" => ci.provider.id, "provider_name" => ci.provider.name, "provider_address" => ci.provider.address, "provider_website" => ci.provider.website, "price" => ci.actual_price}}.take(number_of_prices) ]}
      catalogue_items = Hash[catalogue_items]
    rescue Exception => e
      Rails.logger.fatal "Error while getting prices from other for account #{account.inspect} : #{e.message}"
      return nil
    end
    

    
  end
  
end