class CreateStores < ActiveRecord::Migration
  def change
    create_table :stores do |t|
      t.string :address
      t.integer :city_id

      t.timestamps
    end
  end
end
