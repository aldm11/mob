require 'open-uri'
require 'json'

def brands_filename
  File.expand_path("../phone_brands.json", __FILE__)
end

def models_filename
  File.expand_path("../phone_models.json", __FILE__)
end

def details_filename
  File.expand_path("../phone_details.json", __FILE__)
end

open("http://www.handsetdetection.com/apiv3/device/vendors.json", "Authorization" => %Q{Digest username="85af651535", realm="APIv3", nonce="APIv3", uri="/apiv3/device/vendors.json", response="fbff703672c744847de0f20e2b744628", opaque="APIv3", qop=auth, nc=00000002, cnonce="e401bf33544bdebe"}) { |brands|
  #puts "dokument #{f.read.inspect}"
  brands = JSON.parse(brands.read)["vendor"]
  
  #writing brands to file
  File.open(brands_filename, "w") do |f|
    f.write(JSON.pretty_generate({"brands" => brands }))
  end
  
  brands_models = {}
  brands.each do |brand|
    uri = URI.escape("http://www.handsetdetection.com/apiv3/device/models/#{brand}.json")
    puts "Getting models for brand #{brand}"
    open(uri, "Authorization" => %Q{Digest username="85af651535", realm="APIv3", nonce="APIv3", uri="/apiv3/device/vendors.json", response="fbff703672c744847de0f20e2b744628", opaque="APIv3", qop=auth, nc=00000002, cnonce="e401bf33544bdebe"}) { |models|
      brands_models[brand] = JSON.parse(models.read)["model"]
    }
  end
  #writing models to file
  File.open(models_filename, "w") do |f|
    f.write(JSON.pretty_generate({"models" => brands_models }))
  end
  
  details = {}
  brands_models.each do |brand, models|
    details[brand] = {}
    models.each do |model| 
      puts "Getting details for brand #{brand} model #{model}"
      uri = URI.escape("http://www.handsetdetection.com/apiv3/device/view/#{brand}/#{model}.json")#.gsub(" ", "%20")
      begin
        open(uri, "Authorization" => %Q{Digest username="85af651535", realm="APIv3", nonce="APIv3", uri="/apiv3/device/vendors.json", response="fbff703672c744847de0f20e2b744628", opaque="APIv3", qop=auth, nc=00000002, cnonce="e401bf33544bdebe"}) do |detail|
          details[brand][model] = JSON.parse(detail.read)["device"]
        end      
      rescue Exception => e
        puts "Error getting details for brand #{brand} model #{model} : #{e.message}"
      end
    end unless models.nil?
  end
  #writing details to file
  File.open(details_filename, "w") do |f|
    f.write(JSON.pretty_generate(details))
  end
  
}
