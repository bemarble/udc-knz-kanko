class ChangeUsers < ActiveRecord::Migration
  def change
    change_table :users do |t|
      t.string :aaa
    end
  end
end
