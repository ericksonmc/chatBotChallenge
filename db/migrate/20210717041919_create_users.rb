class CreateUsers < ActiveRecord::Migration[6.1]
  def change
    create_table :users do |t|
      t.string :name
      t.integer :telegram_id
      t.integer :root_id
      t.integer :step

      t.timestamps
    end
  end
end
