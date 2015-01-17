class AddColumnUsers001 < ActiveRecord::Migration
  def change

    add_index :users, :twitter
    add_index :users, :facebook
  end
end
