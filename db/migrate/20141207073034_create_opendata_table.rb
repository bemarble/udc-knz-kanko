class CreateOpendataTable < ActiveRecord::Migration
  def change
    create_table :opendatas do |t|
      t.string :name
      t.timestamps
    end
  end
end
