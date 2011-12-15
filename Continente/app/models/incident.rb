class Incident < ActiveRecord::Base
  belongs_to :category
  belongs_to :supplier
  belongs_to :storage
  belongs_to :store
  belongs_to :office
  def to_string
    return "Incident #{id}"
  end
end
