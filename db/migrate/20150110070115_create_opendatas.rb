class CreateOpendatas < ActiveRecord::Migration
  def change
    create_table :opendatas do |t|
      t.integer :id
      t.float :latitude
      t.float :longitude
      t.string :name
      t.string :desc
      t.string :tel
      t.string :url
      t.timestamps  #=> この一行でcreated_atとupdated_atのカラムが定義される
    end
  end
end
