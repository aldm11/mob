module DeviseHelper


  # A simple way to show error messages for the current devise resource. If you need
  # to customize this method, you can either overwrite it in your application helpers or
  # copy the views to your application.
  #
  # This method is intended to stay simple and it is unlikely that we are going to change
  # it to add more behavior or options.
  def devise_error_messages!


    return "" if resource.errors.empty?

    #messages = resource.errors.full_messages.map { |msg| content_tag(:li, msg) }.join
    # messages = resource.errors.full_messages.map { |msg| content_tag(:span, msg) }.join(".")
    messages = resource.errors.full_messages.map { |msg| content_tag(:li, msg) }.join(".")
    puts "errors #{resource.errors.messages[:email].inspect}"
    sentence = I18n.t("errors.messages.not_saved",
                      :count => resource.errors.count,
                      :resource => resource.class.model_name.human.downcase)

    # html = <<-HTML
    # <div id="error_explanation" class="alert alert-error">
      # <h2>#{sentence}</h2>
      # <ul>#{messages}</ul>
    # </div>
    # HTML
    
     html = <<-HTML
    <div id="error_explanation" class="alert alert-error">
      <a class="close" data-dismiss="alert" href="#">&times;</a>
      <li>
        #{messages}
      </li>
    </div>
    HTML

    html.html_safe
  end
  
  def after_sign_in_path_for(resource_or_scope)
    scope = Devise::Mapping.find_scope!(resource_or_scope)
    home_path = "#{scope}_phones_path"    
    respond_to?(home_path, true) ? send(home_path) : phones_path
  end
  
end

