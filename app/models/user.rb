class User < ApplicationRecord
  has_many :bots
  has_many :orders
  has_many :paper_requests

  enum step: { 
    deposits: 1,
    paper_roll_request: 2,
    economic_indicators: 3,
    getting_date_deposits: 4,
    getting_address: 5,
    getting_quantity: 6,
    getting_indicator: 7
  }
end
