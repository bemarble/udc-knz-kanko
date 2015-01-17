class RemoveColumnUsers < ActiveRecord::Migration
  def change
    change_table :users do |t|
      t.string :none
      t.string :want2go
      t.integer :helpme
      t.remove :none
      t.remove :want2go
      t.remove :helpme
    end
  end
end
