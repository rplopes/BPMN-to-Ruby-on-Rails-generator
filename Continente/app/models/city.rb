class City < ActiveRecord::Base
  def to_string
    return name
  end
end
