class CreatePosts < ActiveRecord::Migration
  def change
    create_table :posts do |t|
      t.integer :user_id
      t.integer :post_type, :default => 1
      t.text :message
      t.float :latitude, :limit => 8, :scale => 6
      t.float :longitude, :limit => 9, :scale => 6
      t.timestamps
    end
  end
end
