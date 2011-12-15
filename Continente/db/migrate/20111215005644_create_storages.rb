class CreateStorages < ActiveRecord::Migration
  def change
    create_table :storages do |t|
      t.string :address
      t.integer :city_id

      t.timestamps
    end
  end
end
