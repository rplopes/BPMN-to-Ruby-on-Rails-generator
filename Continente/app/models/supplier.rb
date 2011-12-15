class Supplier < ActiveRecord::Base
  belongs_to :city
  def to_string
    return "#{city.to_string} - #{name}"
  end
end
