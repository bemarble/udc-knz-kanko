class CreateOpendatas < ActiveRecord::Migration
  def change
    create_table :opendatas do |t|
      t.integer :open_id
      t.float :latitude
      t.float :longitude
      t.string :name
      t.string :desc
      t.string :tel
      t.string :url
      t.timestamps
    end
  end
end
