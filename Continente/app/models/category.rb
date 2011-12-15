class Category < ActiveRecord::Base
  def to_string
    return name
  end
end
