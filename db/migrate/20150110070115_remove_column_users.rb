class RemoveColumnUsers < ActiveRecord::Migration
  def change
    change_table :users do |t|
      t.datetime :updated_at
      t.string :none
      t.string :want2go
      t.integer :helpme
      t.remove :updated_at
      t.remove :none
      t.remove :want2go
      t.remove :helpme
    end
  end
end
