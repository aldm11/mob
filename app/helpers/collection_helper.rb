module CollectionHelper
  
  def divide_in_groups(items, group_size)
    data = {}
    counter = 0
    group = 0
    items.each do |item|
      data[group.to_s] ||= []
      data[group.to_s] << item
      counter += 1
      if counter == group_size
        counter = 0
        group += 1
      end
    end
    data
  end
  
end