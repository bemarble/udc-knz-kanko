class AddColumnUsers001 < ActiveRecord::Migration
  def change
    change_table :users do |t|
      t.timestamp :updated_at
    end

    add_index :users, :twitter
    add_index :users, :facebook
  end
end
