class Incident < ActiveRecord::Base

  belongs_to :category
  belongs_to :supplier
  belongs_to :storage
  belongs_to :store
  belongs_to :office

  acts_as_ferret :fields => [:description]
  acts_as_ferret :additional_fields => [:category_name, :store_name, :supplier_name, :office_name]
	
	def category_name
	  category.to_string
	end

	def store_name
	  store.to_string
	end

	def supplier_name
	  supplier.to_string
	end

	def office_name
		office.to_string
	end

  def to_string
    return "Incident #{id}"
  end
end
