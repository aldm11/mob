require "open-uri"

module Managers
  module PhoneManager
    
    ATTRIBUTES_FILENAME = "attributes.json"
    ATTRIBUTES_ROOT = "attributes"
    
    def self.add_phone(p)
      pho = prepare_params(p)
      result = {}
     
      if phone = phone_exists?(pho)
        phone.update_attributes(pho) if pho
        result[:message] = "Phone updated"
      else
        phone = Phone.new(pho)
        result[:message] = "Phone added"
      end
      
      result[:phone] = phone
      if phone.save(:validate => false)
        result[:status] = true
      else
        result[:status] = false
        result[:message] = "Phone not valid"
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

    def self.phone_exists?(phone)
      p = Phone.where(:brand => phone[:brand], :model => phone[:model]).to_a
      p.empty? ? false : p.first
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
    
    ### ONE PHONE FUNCTIONS
    DEFAULT_OFFERS = {:all_offers => [], :related_offers => [], :min_price => 0, :max_price => 0, :to => 0}
    def self.get_offers(phone, options = {})
      phone = Phone.find(phone) if phone.is_a?(String)
      return DEFAULT_OFFERS if phone.catalogue_items.empty?
      
      all_offers = phone.catalogue_items.select {|ci| ci.deleted_date.nil? }
      return DEFAULT_OFFERS if all_offers.empty?
      
      if options[:sort_by] == "date"
        all_offers.sort! {|a, b| b.date_from <=> a.date_from} 
      elsif options[:sort_by] == "price"
        all_offers.sort! {|a, b| a.actual_price <=> b.actual_price} 
      end
      
      from = options[:from] || 0
      to = options[:to] || all_offers.length - 1
      to = all_offers.length-1 if to > all_offers.length - 1        
      related_offers = all_offers[from..to]
     
      prices = related_offers.map { |ci| ci.actual_price }.sort
      min_price = prices.first
      max_price = prices.last
      
      result = DEFAULT_OFFERS.merge({:all_offers => all_offers, :related_offers => related_offers, :min_price => min_price, :max_price => max_price, :to => to})
      result
    end
    
    DEFAULT_COMMENTS = {:all_comments => [], :related_comments => [], :to => 0}
    def self.get_comments(phone, options = {})
      phone = Phone.find(phone) if phone.is_a?(String)
      return DEFAULT_COMMENTS if phone.comments.empty?
      
      all_comments = phone.comments.select {|comm| comm.active}
      return DEFAULT_COMMENTS if all_comments.empty?
      
      if options[:sort_by] == "date"
        all_comments.sort! {|a, b| b.created_at <=> a.created_at}
      end
      
      if options[:from] && options[:to]
        from = options[:from]
        to = options[:to]
        to = all_comments.length-1 if to > all_comments.length - 1
        related_comments = all_comments[from..to]      
      else
        to  = 0
        related_comments = all_comments
      end
      
      result = DEFAULT_COMMENTS.merge({:all_comments => all_comments, :related_comments => related_comments, :to => to})
      result
    end
    
  end
end