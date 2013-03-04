{:bs => 
  { :i18n => 
    { :plural => 
      { :keys => [:one, :other],
        :rule => lambda { |n| 
          if n == 1
            :one
          elsif n > 1 && n < 10
            :few
          else
            :other 
          end
        } 
      } 
    } 
  } 
}