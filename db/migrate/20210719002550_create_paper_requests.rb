class CreatePaperRequests < ActiveRecord::Migration[6.1]
  def change
    create_table :paper_requests do |t|
      t.string :rut
      t.integer :quantity
      t.references :user, null: false, foreign_key: true
      t.float :amount, default: 0
      t.text :address
      t.integer :status, default: 0

      t.timestamps
    end
  end
end
