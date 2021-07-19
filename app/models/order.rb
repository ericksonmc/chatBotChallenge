class Order < ApplicationRecord
  belongs_to :user
  enum status: { pending: 0, deposited: 1 }

end
