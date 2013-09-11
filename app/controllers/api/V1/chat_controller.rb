class Api::V1::ChatController < ApplicationController

  def get_conf
    config_file_content = File.read(File.expand_path("../../../../../config/config.yml", __FILE__))

    config_content = YAML.load(config_file_content)
    chat_config = config_content["chat"]
    puts "konf #{chat_config.inspect}"
    
    render :json => chat_config
  end

end
