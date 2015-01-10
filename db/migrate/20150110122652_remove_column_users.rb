class RemoveColumnUsers < ActiveRecord::Migration
  def change
    change_table :users do |t|
      t.remove :updated_at
      t.remove :none
      t.remove :want2go
      t.remove :helpme
    end
  end
end
