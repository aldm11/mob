require "open-uri"

module Managers
  module PhoneManager
    
    ATTRIBUTES_FILENAME = "attributes.json"
    ATTRIBUTES_ROOT = "attributes"
    
    def self.add_phone(phone)
      phone = prepare_params(phone)
      phone = Phone.new(phone)
      result = {:phone => phone}
     
      if phone_exists(phone)
        result[:status] = false
        result[:message] = "Phone exists"
      else
        if phone.save
          result[:status] = true
        else
          result[:status] = false
          result[:message] = "Phone not valid"
        end
      end
      result
    end
    
    def self.prepare_params(phone)
      if phone[:flickrimg]
        phone[:image] = URI.parse(phone[:flickrimg])
      elsif phone[:amazon]
        phone[:image] = URI.parse(phone[:amazon])
      end
      phone
    end

    def self.phone_exists(phone)
      Phone.where(:brand => phone.brand, :model => phone.model).exists?
    end
    
    def self.get_phones(options = {})
      phones = Phone.where(options).to_a
    end
    
    def self.add_comment(phone_id, comment)
      phone = Phone.find(phone_id)
      comment = Comment.new(comment)
      result = {:comment => comment, :phone => phone}
      if comment.save
        result[:status] = true
      else
        result[:status] = false
      end
    end
    
    def self.check_and_create_attributes_file(filename = nil)
      filename = file_path(filename)
      unless File.exists?(filename)
        write_attributes_to_file([], filename)
      end
    end
    
    def self.file_path(filename)
      filename = ATTRIBUTES_FILENAME unless filename
      filename = File.expand_path("../" + filename, __FILE__) unless filename.include?("/")
      filename
    end
    
    REQUIRED_FIELDS = ["name"]
    EXISTING_FIELDS = ["name", "unit"]
    UNEXISTING_REPLACEMENT = "-"
    def self.parse_attribute(attribute)
      return nil unless REQUIRED_FIELDS.all? { |attr| attribute.has_key?(attr) && attribute[attr].is_a?(String) && !attribute[attr].blank? }

      attribute = attribute.select { |key, value| EXISTING_FIELDS.include?(key) && value.is_a?(String) && !value.blank? }
      attribute
    end
    
    def self.get_all_attributes
      attributes = add_blank_unexisting_values(get_attributes)
    end
    
    def self.add_blank_unexisting_values(attributes)
      attributes = [attributes].flatten
      attributes.each_with_index do |attribute, index|
        EXISTING_FIELDS.each do |field|
          unless attribute.has_key?(field)
            field_hash = {}
            field_hash[field] = UNEXISTING_REPLACEMENT
            attributes[index].merge!(field_hash)
          end
        end
      end
      attributes
    end
    
    def self.add_phone_attribute(attribute, filename = nil)
      filename = file_path(filename)
      attribute = parse_attribute(attribute)
      
      attributes = ""
      file = File.open(filename, "r") do |f|
        attributes = JSON.parse(f.read)
      end
      attributes = attributes[ATTRIBUTES_ROOT]
            
      result = {:attribute => attribute}
      if attribute
        exists = attributes.any? { |attr| attr["name"] == attribute["name"] }
        if exists
          result[:status] = false
          result[:message] = "Attribute exists"
        else
          result[:status] = true
          result[:message] = "Attribute added"
          attributes << attribute
        end
      else
        result[:status] = false
        result[:message] = "Attribute not valid"
      end
      
      write_attributes_to_file(attributes, filename)
      result
            
    end
    
    def self.write_attributes_to_file(attributes, filename)
      content = {}
      content[ATTRIBUTES_ROOT] = attributes
      
      File.open(filename, "w") do |f|
        f.write(JSON.pretty_generate(content))
      end
    end
    
    def self.clear_attributes(filename = nil)
      filename = file_path(filename)
      write_attributes_to_file([], filename)
    end
    
    def self.get_attributes(filename = nil)
      filename = file_path(filename)
      attributes = ""
      File.open(filename, "r") do |f|
        attributes = JSON.parse(f.read)[ATTRIBUTES_ROOT]
      end
      attributes
    end
    
    def self.attribute_fields
      EXISTING_FIELDS
    end
    
    def self.delete_file(filename = nil)
      filename = file_path(filename)
      File.open(filename, "r") do |f|
        
      end
      File.unlink(filename)
    end
    
    POPULAR_BRANDS = ["Samsung", "HTC", "Apple", "LG"]
    def self.get_initial_phones(options = {})
      offset = options[:offset] || 0
      limit = options[:limit] || 10
      #TODO: sort this by something ?
      #TODO: enable paging
      phones_in_sale = Phone.where(:latest_prices_size.gt => 0)
      phones_in_sale = phones_in_sale.where(brand: options[:brand]) if options[:brand]
      phones_in_sale = phones_in_sale.desc("latest_price.created_at").skip(offset).limit(limit).to_a
      
      #TODO: remove this when there is enought phones in catalogue
      if phones_in_sale.length < limit
        until_limit = limit - phones_in_sale.length
        phones_not_in_sale = Phone.all.in(latest_prices_size: [nil, 0]).in(brand: POPULAR_BRANDS).limit(until_limit).to_a
        phones_in_sale.push(phones_not_in_sale)
        phones_in_sale = phones_in_sale.flatten
      end
      phones_in_sale
    end
    
  end
end