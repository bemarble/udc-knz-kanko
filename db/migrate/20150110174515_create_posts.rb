class CreatePosts < ActiveRecord::Migration
  def change
    create_table :posts do |t|
      t.integer :user_id
      t.text :message
      t.datetime :created_at
      t.timestamp :updated_at

    end
  end
end
