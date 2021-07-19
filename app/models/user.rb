class User < ApplicationRecord
  include AASM
  has_many :bots, dependent: :destroy
  has_many :orders, dependent: :destroy
  has_many :paper_requests, dependent: :destroy

  #steps for telegram bot  
  enum step: { 
    deposits: 1,
    paper_roll_request: 2,
    economic_indicators: 3,
    getting_date_deposits: 4,
    getting_address: 5,
    getting_quantity: 6,
    getting_indicator: 7
  }

  aasm do
    state :menu, initial: true
    state :deposits
    state :papper
    state :economic_indicators


    event :to_menu do
      transitions from: [:deposits,:papper, :menu, :economic_indicators], to: :menu
      after { send_menu_message }
    end

    event :to_deposits do
      transitions from: :menu, to: :deposits
      
      after { send_deposit_message }
    end

    event :to_paper_roll_request do
      transitions from: :menu, to: :papper, guard: :has_order_payments?

      after { send_paper_request_message }
    end

    event :to_economic do
      transitions from: :menu, to: :economic_indicators

      after { send_economic_message }
    end
  end

  private

  def send_menu_message
    sleep 1
    broadcast_action(menu: true, message: { user_id: self.id })
  end

  def send_deposit_message
    broadcast_action(menu: false, message: { message: I18n.t(:indicated_rut) })
  end

  def send_paper_request_message
    broadcast_action(menu: false, message: { message: I18n.t(:rut_address_quantity) })
  end

  def has_order_payments?
    orders = self.orders.where(status: 'pending', date_to_send: Date.tomorrow)

    if orders.present?
      return orders.present?
    else
      broadcast_action(menu: false, message: { message: I18n.t(:not_balance) })
      sleep 1
      self.to_menu!
      return false
    end

    raise ErrorToTransitionByGuard, self
  end

  def send_economic_message
    broadcast_action(menu: false, message: { message: I18n.t(:question_indicator) })
  end

  private
  
  def broadcast_action(menu: false, message: {}, current_user: nil)
    ActionCable.server.broadcast 'room_channel', content: { type: 0, menu: menu, message: message }
  end
end
