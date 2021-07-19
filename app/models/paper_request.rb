class PaperRequest < ApplicationRecord
  belongs_to :user
  enum status: { creating: 0, pending: 1, sended: 2 }
  after_create :set_order_id
  

  def set_order_id
    self.update(order_id: SecureRandom.hex(8))
  end
end
