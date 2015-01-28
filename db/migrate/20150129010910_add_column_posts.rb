class AddColumnPosts < ActiveRecord::Migration
  def change

    add_column :posts, :help, :integer, :default => 0
    add_column :posts, :open_id, :integer


    remove_column :posts, :post_type
  end
end
