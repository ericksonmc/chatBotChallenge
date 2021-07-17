require File.expand_path('../config/environment', __dir__)
require 'telegram/bot'

token = "1875305838:AAEviN25QHA6T9NZ_vaHJCF4IhKFnVGBDQw"
def update_step(step)
  @user.update(step: step)
end

def clear_step
  @user.update(step: nil)
end

def find_user(telegram_id, first_name)
  user = User.find_by(telegram_id: telegram_id)
  unless user.present?
    user = User.create(telegram_id: telegram_id, name: first_name)
  end
  user
end

def find_deposits(date)
  date = Date.strptime(date,'%d/%m/%Y')
  order = Order.find_by(rut: @user.rut, date_to_send: date)
  
  return order
end

def parse_amount(amount)
  return ActionController::Base.helpers.number_to_currency(amount)
end

Telegram::Bot::Client.run(token) do |bot|
  bot.listen do |message|
    @user = find_user(message.from.id, message.from.first_name)

    case @user.step
    when 'deposits'
      @user.update(rut: message.text)
      if Order.where(rut: message.text).blank?
        bot.api.send_message(chat_id: message.chat.id, text: "Rut no encontrado, Intentelo nuevamente")
      else
        bot.api.send_message(chat_id: message.chat.id, text: "Indique la fecha")
        update_step('getting_date_deposits')
      end
    when 'getting_date_deposits'
      deposits = find_deposits(message.text)
      if deposits.present?
        bot.api.send_message(chat_id: message.chat.id, text: "Deposito pendiente para la fecha indicada es de: \nMonto: #{parse_amount(deposits.amount)} \nFecha: #{deposits.date_to_send}")
        clear_step
      else
        bot.api.send_message(chat_id: message.chat.id, text: "No tiene depositos para la fecha indicada, puede indicar otra")
      end
    when 'paper_roll_request'
      clear_step
    when 'economic_indicators'
      clear_step
    end

    case message.text
    when '/start'
      main_menu = ['/depositos','/papel','/economia']
      markup = Telegram::Bot::Types::ReplyKeyboardMarkup.new(keyboard: main_menu)
      clear_step
      bot.api.send_message(chat_id: message.chat.id, text: "Para empezar escoge una opcion del menu", reply_markup: markup)
    when '/depositos'
      update_step('deposits')
      bot.api.send_message(chat_id: message.chat.id, text: "Enviame tu Rut")
    when '/papel'
      update_step('paper_roll_request')
      bot.api.send_message(chat_id: message.chat.id, text: "Pick bot to delete")
    when '/economia'
      update_step('economic_indicators')
      bot.api.send_message(chat_id: message.chat.id, text: "Send me your question")
    end
  end
end