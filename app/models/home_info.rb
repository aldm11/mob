class HomeInfo
  
  def initialize
    @all_phones = Phone.all.to_a
  end
  
  def latest_phones(options = {})
    @phones = Managers::PhoneManager.get_initial_phones(options)
    PhoneDecorator.decorate(@phones)    
  end
  
  def brands
    brands = @all_phones.map { |phone| phone.brand }
    brands.uniq!
  end

end