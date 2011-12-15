class Storage < ActiveRecord::Base
  belongs_to :city
  def to_string
    return "#{city.to_string} - #{address}"
  end
end
