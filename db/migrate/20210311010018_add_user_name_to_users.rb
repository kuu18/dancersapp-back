class AddUserNameToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :user_name, :string, null: false, after: :name
  end
end
