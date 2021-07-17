class CreateOrders < ActiveRecord::Migration[6.1]
  def change
    create_table :orders do |t|
      t.references :user, null: false, foreign_key: true
      t.float :amount
      t.integer :status
      t.date :date_to_send
      t.string :rut

      t.index :rut

      t.timestamps
    end
  end
end
