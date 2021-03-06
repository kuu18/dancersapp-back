class AddActivationToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :activated, :boolean, null: false, default: false
  end
end
