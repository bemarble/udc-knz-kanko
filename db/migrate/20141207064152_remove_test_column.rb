class RemoveTestColumn < ActiveRecord::Migration
  def change
    change_table :users do |t|
      t.remove :aaa
    end
  end
end
