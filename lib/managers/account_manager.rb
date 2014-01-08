module Managers
  module AccountManager
    
    SETTINGS = {
      :name => {:display => "Ime"},
      :username => {:display => "Korisnicko ime", :value_pattern => /[a-z0-9]+{6,20}/},
      :phone => {:display => "Telefon", :limit => 3, :value_pattern => /^[0-9]+{8,20}$/},
      :fax => {:limit => 3, :display => "Fax", :value_pattern => /^[0-9]+{8,20}$/},
      :address => {:limit => 4, :display => "Adresa"},
      :website => {:limit => 3, :display => "Website", :value_pattern => /^(([\w]+:)?\/\/)?(([\d\w]|%[a-fA-f\d]{2,2})+(:([\d\w]|%[a-fA-f\d]{2,2})+)?@)?([\d\w][-\d\w]{0,253}[\d\w]\.)+[\w]{2,4}(:[\d]+)?(\/([-+_~.\d\w]|%[a-fA-f\d]{2,2})*)*(\?(&amp;?([-+_~.\d\w]|%[a-fA-f\d]{2,2})=?)*)?(#([-+_~.\d\w]|%[a-fA-f\d]{2,2})*)?$/}
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
          display_property = SETTINGS[property.to_sym][:display] || property.to_s.camelize
          "#{display_property.to_s} ne moze imati vise vrijednosti."
        else
          nil          
        end
      end.compact
      return {:status => false, :message => invalid_properties.join(" ")} unless invalid_properties.empty?
            
      forbidden_properties = properties.map { |property, values| SETTINGS[property.to_sym] ? nil : property }.compact
      transform_for_display(forbidden_properties)
      return {:status => false, :message => "#{forbidden_properties.join(" ")} se ne moze promijeniti"} unless forbidden_properties.empty?
      
      invalid_values = properties.map do |property, value|
        invalids = [value].flatten.select { |val| SETTINGS[property.to_sym][:value_pattern] && val.match(SETTINGS[property.to_sym][:value_pattern]).nil? }
        display_property = SETTINGS[property.to_sym][:display] || property.to_s.camelize
        invalids.empty? ? nil : "Neispravan format #{invalids.first.to_s} za #{display_property.to_s}."
      end.compact
      return {:status => false, :message => invalid_values.join(" ")} unless invalid_values.empty?
      
      limit_excedded_properties = properties.map do |property, value|
        existing_length = account_attributes[property.to_sym] ? account_attributes[property.to_sym].length : 0
        if SETTINGS[property.to_sym][:limit] && [value].flatten.length + existing_length > SETTINGS[property.to_sym][:limit]
          display_property = SETTINGS[property.to_sym][:display] || property.to_s.camelize
          "Nije moguce dodati vise od #{SETTINGS[property.to_sym][:limit]} #{display_property}"
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
      properties_names = properties.keys.map { |property| property.to_s }
      transform_for_display(properties_names)
      {:status => true, :message => "#{properties_names.join(", ")} uspjesno promijenjen", :attributes => new_properties}
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
          display_property = SETTINGS[property.to_sym][:display] || property.to_s.camelize
          "#{display_property.to_s} ne moze imati vise vrijednosti"
        end
      end.compact
      return {:status => false, :message => invalid_properties.join(" ")} unless invalid_properties.empty?
            
      forbidden_properties = properties.map { |property, values| SETTINGS[property.to_sym] ? nil : property }.compact
      transform_for_display(forbidden_properties)
      return {:status => false, :message => "#{forbidden_properties.join(" ")} se ne moze promijeniti"} unless forbidden_properties.empty?
      
      new_properties = {}
      properties.each do |property, value|
        target_object = current_account.fields[property.to_s] ? current_account : current_account.rolable
        existing_value = target_object.attributes[property.to_s]
        existing_value = [] if existing_value.nil?
        new_values = existing_value - [value].flatten
        target_object.update_attributes(property.to_s => new_values) 
        new_properties[property.to_s] = new_values    
      end
      
      properties_names = properties.keys
      transform_for_display(properties_names)
      message = "#{properties_names.join(", ")} uspjesno obrisan"
      {:status => true, :message => message, :attributes => new_properties.with_indifferent_access}
    end
    
    def self.transform_for_display(properties)
      properties.map! { |property| SETTINGS[property.to_sym] ? SETTINGS[property.to_sym][:display] || property.to_s.camelize : nil }
    end  
    
    def self.editable?(property)
      SETTINGS.keys.map { |p| p.to_s }.include?(property.to_s)
    end
    
  end
end