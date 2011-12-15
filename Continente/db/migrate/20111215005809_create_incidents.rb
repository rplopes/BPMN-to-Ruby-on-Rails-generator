class CreateIncidents < ActiveRecord::Migration
  def change
    create_table :incidents do |t|
      t.string :description
      t.string :resolution
      t.integer :category_id
      t.integer :supplier_id
      t.integer :storage_id
      t.integer :store_id
      t.integer :office_id
      t.integer :impact
      t.integer :urgency

      t.timestamps
    end
  end
end
