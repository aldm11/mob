require 'open-uri'

module Importers
  module Database
    module PhoneImporter
      
      MODEL_JSON_MAPPINGS = {
        :brand => {
          :json_dimensions => "general_vendor",
          :mapping => lambda{ |dimensions| dimensions.blank? ? "": dimensions }
        },
        :model => {
          :json_dimensions => "general_model",
          :mapping => lambda{ |dimensions| dimensions.blank? ? "" : dimensions }
        },
        :os => {
          :json_dimensions => "general_platform",
          :mapping => lambda { |dimensions| dimensions.blank? ? "" : dimensions }
        },
        :camera => {
          :json_dimensions => "media_camera",
          :mapping => lambda { |dimensions| 
            return {:all => dimensions} if dimensions.is_a?(String)
            all = dimensions[0]
            all += " " + dimensions[1] if dimensions.length > 1
            all
          }
        },
        :height => {
          :json_dimensions => "design_dimensions",
          :mapping => lambda { |dimensions| dimensions.blank? || !dimensions.include?("x") ? "" : dimensions.split("x")[0].strip }
        },
        :width => {
          :json_dimensions => "design_dimensions",
          :mapping => lambda { |dimensions| dimensions.blank? || !dimensions.include?("x")  ? "" :  dimensions.split("x")[1].strip }
        },
        :weight => {
          :json_dimensions => "design_weight",
          :mapping => lambda { |dimensions| dimensions.blank? ? "" : dimensions }
        },
        :display  => {
          :json_dimensions => ["display_type", "display_colors", "display_x", "display_y"],
          :mapping => lambda { |dimensions|
            return dimensions if dimensions.is_a?(String)
            result = dimensions[0]
            result += " " + dimensions[1] if dimensions.length > 1
            result += dimensions[2] + "x" + dimensions[3] if dimensions.length > 2
            result
          }
        },
        :amazon_image_small => {
          :json_dimensions => "general_image",
          :mapping => lambda { |dimensions| "http://hdimages-80.s3.amazonaws.com/" + dimensions }
        },
        :amazon_image_medium => {
          :json_dimensions => "general_image",
          :mapping => lambda { |dimensions| "http://hdimages-160.s3.amazonaws.com/" + dimensions }
        }
        
      }
      
      def import_phones_from_json(options = {})
        raise "No brand specified" if options.blank? || options[:brand].blank?
        
        DataStore::Memory::PhoneDetails.import_data_from_json_file
        phones = DataStore::Memory::PhoneDetails.phones 
  
        brands = options[:brand] ? [options[:brand]].flatten :  [phones.keys]
        
        brands.each do |brand|
          brand_models = DataStore::Memory::PhoneDetails.get_brand(brand)
          
          puts "Importing brand #{brand}"
          
          brand_models.each do |model, details|
            unless details.blank?
              phone = create_phone_from_json(details)
              puts "Importing phone #{phone.inspect}" 
              result = Managers::PhoneManager.add_phone(phone)
              
              if result[:status]
                puts "Phone imported"
              else
                puts "Phone not imported : #{result[:message]}"
              end
            end
          end unless brand_models.blank?
        end
      end
      
      def import_phones_images_from_json(options = {})
        raise "No brand specified" if options.blank? || options[:brand].blank?
        
        DataStore::Memory::PhoneDetails.import_data_from_json_file
        phones = DataStore::Memory::PhoneDetails.phones 
  
        brands = options[:brand] ? [options[:brand]].flatten :  [phones.keys]

        brands.each do |brand|
          phones = Phone.where(brand: brand).to_a
          phones.each do |phone|
            import_phone_images(phone)
          end
        end
      end
      
      private
      def create_phone_from_json(details)
        phone_hash = {}
            
        MODEL_JSON_MAPPINGS.each do |attribute, attr_opts|
          dimensions = []
          [attr_opts[:json_dimensions]].flatten.each do |opt|
            dimensions << details[opt]
          end
          dimensions = dimensions.first if dimensions.length == 1
          attr = {}
          attr[attribute] = attr_opts[:mapping].call(dimensions)
          phone_hash.merge!(attr)
        end
        phone_hash
      end
      
      
      IMAGES_DIMENSIONS = [:amazon_image_small, :amazon_image_medium]
      def import_phone_images(phone)
        Rails.logger.debug "Importing images for phone #{phone.name}"
        IMAGES_DIMENSIONS.each do |image|
          begin
            url = phone.attributes[image.to_s]     
            remote_photo = open(URI.escape(url))
            def remote_photo.original_filename;base_uri.path.split('/').last; end    
            phone.send(image.to_s + "_full" + "=", remote_photo)
          rescue Exception => e
            Rails.logger.debug "Cant get image for phone #{phone} from url #{url} #{e.message}"
          end
        end
        phone.save
        rescue Exception => e
          Rails.logger.info "Problem importing images #{e.message}"
      end 
    end
  end
end