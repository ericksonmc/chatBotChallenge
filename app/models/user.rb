class User < ApplicationRecord
  has_many :bots
  has_many :orders

  enum step: { deposits: 1, paper_roll_request: 2, economic_indicators: 3, getting_date_deposits: 4 }
end
