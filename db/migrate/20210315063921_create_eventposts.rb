class CreateEventposts < ActiveRecord::Migration[6.0]
  def change
    create_table :eventposts do |t|
      t.text :content, null: false
      t.string :event_name, null: false
      t.datetime :event_date, null: false
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
    add_index :eventposts, [:user_id, :event_date]
  end
end
