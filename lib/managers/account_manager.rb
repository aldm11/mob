module Managers
  module AccountManager
    
    SETTINGS = {
      :name => {},
      :username => {},
      :phone => {:limit => 3, :value_pattern => /^[0-9]+{8,20}$/},
      :fax => {:limit => 3, :value_pattern => /^[0-9]+{8,20}$/},
      :address => {:limit => 4},
      :website => {:limit => 3, :value_pattern => /^(([\w]+:)?\/\/)?(([\d\w]|%[a-fA-f\d]{2,2})+(:([\d\w]|%[a-fA-f\d]{2,2})+)?@)?([\d\w][-\d\w]{0,253}[\d\w]\.)+[\w]{2,4}(:[\d]+)?(\/([-+_~.\d\w]|%[a-fA-f\d]{2,2})*)*(\?(&amp;?([-+_~.\d\w]|%[a-fA-f\d]{2,2})=?)*)?(#([-+_~.\d\w]|%[a-fA-f\d]{2,2})*)?$/}
    }
    
    def self.add(current_account, properties)
      account_attributes = if current_account.is_a?(Hash)
        current_account
      elsif current_account.is_a?(AccountDecorator)
        current_account.get_hash
      else
        AccountDecorator.decorate(current_account).get_hash
      end
      
      invalid_properties = properties.map do |property, value|
        field = current_account.fields[property.to_s] ? field = current_account.fields[property.to_s] : current_account.rolable.fields[property.to_s]
        if value.is_a?(Array) && field.options[:type] != Array
          "Invalid add for #{property.to_s}."
        else
          nil          
        end
      end.compact
      return {:status => false, :message => invalid_properties.join(" ")} unless invalid_properties.empty?
            
      forbidden_properties = properties.map { |property, values| SETTINGS[property.to_sym] ? nil : property }.compact
      return {:status => false, :message => "#{forbidden_properties} can't be updated"} unless forbidden_properties.empty?
      
      invalid_values = properties.map do |property, value|
        invalids = [value].flatten.select { |val| SETTINGS[property.to_sym][:value_pattern] && val.match(SETTINGS[property.to_sym][:value_pattern]).nil? }
        invalids.empty? ? nil : "Invalid value #{invalids.first.to_s} for #{property.to_s}."
      end.compact
      return {:status => false, :message => invalid_values.join(" ")} unless invalid_values.empty?
      
      limit_excedded_properties = properties.map do |property, value|
        existing_length = account_attributes[property.to_sym] ? account_attributes[property.to_sym].length : 0
        if SETTINGS[property.to_sym][:limit] && [value].flatten.length + existing_length > SETTINGS[property.to_sym][:limit]
          "Maximum length #{SETTINGS[property.to_sym][:limit]} for #{property.to_s} excedded."
        else
          nil
        end      
      end.compact
      return {:status => false, :message => limit_excedded_properties.join(" ")} unless limit_excedded_properties.empty? 
      
      new_properties = {}
      properties.each do |property, value|
        target_object = current_account.fields[property.to_s] ? current_account : current_account.rolable
        
        if target_object.fields[property.to_s].options[:type] == Array
          values = [value].flatten
          new_value = [account_attributes[property.to_sym], values].flatten.compact.uniq
        else
          new_value = value
        end
        
        target_object.update_attributes(property.to_s => new_value)
        new_properties[property] = new_value
      end
      new_properties = new_properties.with_indifferent_access
      {:status => true, :message => "#{properties.keys.map { |property, value| property.to_s }.join(", ")} succesfully updated", :attributes => new_properties}
    end
    
    def self.remove(current_account, properties)
      account_attributes = if current_account.is_a?(Hash)
        current_account
      elsif current_account.is_a?(AccountDecorator)
        current_account.get_hash
      else
        AccountDecorator.decorate(current_account).get_hash
      end
      
      invalid_properties = properties.map do |property, value|
        if ((field = current_account.fields[property.to_s]) && field.options[:type] == Array) ||
        ((field = current_account.rolable.fields[property.to_s]) && field.options[:type] == Array)
          nil
        else
          "Invalid remove for #{property.to_s}."
        end
      end.compact
      return {:status => false, :message => invalid_properties.join(" ")} unless invalid_properties.empty?
            
      forbidden_properties = properties.map { |property, values| SETTINGS[property.to_sym] ? nil : property }.compact
      return {:status => false, :message => "#{forbidden_properties} can't be removed"} unless forbidden_properties.empty?
      
      new_properties = {}
      properties.each do |property, value|
        target_object = current_account.fields[property.to_s] ? current_account : current_account.rolable
        existing_value = target_object.attributes[property.to_s]
        existing_value = [] if existing_value.nil?
        new_values = existing_value - [value].flatten
        target_object.update_attributes(property.to_s => new_values) 
        new_properties[property.to_s] = new_values    
      end
      
      message = "#{properties.keys.map { |property| property.to_s }.join(", ")} succesfully removed"
      {:status => true, :message => message, :attributes => new_properties.with_indifferent_access}
    end  
    
  end
end