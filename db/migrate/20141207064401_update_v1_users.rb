class UpdateV1Users < ActiveRecord::Migration
  def change
    change_table :users do |t|
      t.string :twitter
      t.string :facebook
      t.string :none
      t.string :want2go
      t.integer :helpme
    end
  end
end
