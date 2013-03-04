module DataStore
  module Memory
    module PhoneDetails
        
      JSON_FILENAME = "phone_details.json"
      JSON_FILENAME_BRANDS = "phone_brands.json"
      mattr_accessor :phones

      def self.import_data_from_json_file
        @@phones ||= File.open(file_path_details, "r") do |f|
          @@phones = JSON.parse(f.read)
        end
      end
      
      def self.file_path_details
        File.expand_path("../../"+JSON_FILENAME, __FILE__)
      end
            
      def self.file_path_brands
        File.expand_path("../../"+JSON_FILENAME_BRANDS, __FILE__)
      end
      
      def self.get_brand(brand)
        return @@phones[brand].clone
      end
      
      def self.get_brands
        brands = []
        File.open(file_path_brands, "r") do |f|
          brands = JSON.parse(f.read)["brands"]
        end
        brands
      end
    end
  end
end