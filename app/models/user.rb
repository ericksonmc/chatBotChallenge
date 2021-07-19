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
    ActionCable.server.broadcast 'room_channel', content: {type: 0, menu: true, user_id: self.id}
  end

  def send_deposit_message
    ActionCable.server.broadcast 'room_channel', content: {type: 0, message: {message: 'Indique su Rut seguido de la fecha a consultar ej: 20236734-a 20/07/2021'}}
  end

  def send_paper_request_message
    ActionCable.server.broadcast 'room_channel', content: {type: 0, message: {message: 'Indique su Rut seguido de la fecha y la cantidad a solicitar Ej: 20236734-a/Calle #34 El portillo/50'}}
  end

  def has_order_payments?
    orders = self.orders.where(status: 'pending', date_to_send: Date.tomorrow)

    if orders.present?
      return orders.present?
    else
      ActionCable.server.broadcast 'room_channel', content: {type: 0, message: {message: 'Saldo insuficiente para generar una orde de papel'}}
      sleep 1
      self.to_menu!
      return false
    end

    raise ErrorToTransitionByGuard, self
  end

  def send_economic_message
    ActionCable.server.broadcast 'room_channel', content: {type: 0, message: {message: 'Cual indicador economico quiere conocer? Opciones: uf, utm'}} 
  end
end
