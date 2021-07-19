class AddOrderIrToPaperRequest < ActiveRecord::Migration[6.1]
  def change
    add_column :paper_requests, :order_id, :string
  end
end
