class UpdateV1Users < ActiveRecord::Migration
  def change
    change_table :users do |t|
      t.string :twitter
      t.string :facebook
      t.string :none
    end
  end
end
