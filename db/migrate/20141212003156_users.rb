class Users < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :name, null: false
    end
  end
end
