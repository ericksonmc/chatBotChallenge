require File.expand_path('../config/environment', __dir__)
require 'telegram/bot'
PRICE_PAPER = 700
TOKEN = "1875305838:AAEviN25QHA6T9NZ_vaHJCF4IhKFnVGBDQw"
def update_step(step)
  @user.update(step: step)
end

def clear_step
  @user.update(step: nil)
end

def find_user(telegram_id, first_name)
  user = User.last
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

def find_order_payment
  @order = @user.orders.where(status: 'pending', date_to_send: Date.tomorrow).last
end

def paper_order_amount(quantity)
  return quantity * PRICE_PAPER
end

def find_paper_order
  @paper_order = @user.paper_requests.where(status: 'creating').last
end

def create_peper_order(rut= nil)
  @paper_order = @user.paper_requests.create(rut: rut)
end

Telegram::Bot::Client.run(TOKEN) do |bot|
  bot.listen do |message|
    @user = find_user(message.from.id, message.from.first_name)
    chat_id = message.chat.id
    message_text = message.text
    main_menu = ['/depositos','/papel','/economia']
    back_menu = ['/Menu']
    indicators = ['UF','UTM']

    #Menu Options
    if message_text.start_with? '/'
      case message_text
      when '/start'
        markup = Telegram::Bot::Types::ReplyKeyboardMarkup.new(keyboard: main_menu)
        clear_step
        bot.api.send_message(chat_id: chat_id, text: "Para empezar escoge una opcion del menu", reply_markup: markup)
      when '/depositos'
        update_step('deposits')
        bot.api.send_message(chat_id: chat_id, text: "Enviame tu Rut")
      when '/papel'
        update_step('paper_roll_request')
        bot.api.send_message(chat_id: chat_id, text: "Enviame tu Rut")
      when '/economia'
        update_step('getting_indicator')
        markup = Telegram::Bot::Types::ReplyKeyboardMarkup.new(keyboard: indicators)
        bot.api.send_message(chat_id: chat_id, text: "Seleccione que indetificador economico desea consultar", reply_markup: markup)
      when '/Menu'
        markup = Telegram::Bot::Types::ReplyKeyboardMarkup.new(keyboard: main_menu)
        bot.api.send_message(chat_id: chat_id, text: "Para empezar escoge una opcion del menu", reply_markup: markup)
        clear_step
      else
        markup = Telegram::Bot::Types::ReplyKeyboardMarkup.new(keyboard: main_menu)
        bot.api.send_message(chat_id: chat_id, text: "Para empezar escoge una opcion del menu", reply_markup: markup)
        clear_step
      end
    else #State Simulations
      case @user.step
      when 'deposits'
        @user.update(rut: message_text)
        bot.api.send_message(chat_id: chat_id, text: "Indique la fecha a consultar Ej: 31/12/2021")
        update_step('getting_date_deposits')
      when 'getting_date_deposits'
        deposits = find_deposits(message_text)
        if deposits.present?
          markup = Telegram::Bot::Types::ReplyKeyboardMarkup.new(keyboard: back_menu)
          bot.api.send_message(
            chat_id: chat_id,
            text: "Deposito pendiente para la fecha indicada es de: \nMonto: #{parse_amount(deposits.amount)} \nFecha: #{deposits.date_to_send.strftime("%d/%m/%Y")}", reply_markup: markup)
          clear_step
        else
          markup = Telegram::Bot::Types::ReplyKeyboardMarkup.new(keyboard: back_menu)
          bot.api.send_message(chat_id: chat_id, text: "No tiene depositos para la fecha indicada", reply_markup: markup)
        end
      when 'paper_roll_request'
        @user.update(rut: message_text)
        if find_order_payment.blank?
          markup = Telegram::Bot::Types::ReplyKeyboardMarkup.new(keyboard: back_menu)
          bot.api.send_message(chat_id: chat_id, text: "No cuenta con saldo para esta operacion", reply_markup: markup)
          clear_step
        else
          update_step('getting_address')
          create_peper_order(message_text)
          bot.api.send_message(chat_id: chat_id, text: "Indique la direccion de despacho")
        end
      when 'getting_address'
        find_paper_order.update(address: message_text)
        update_step('getting_quantity')
        bot.api.send_message(chat_id: chat_id, text: "Indique la cantidad de rollos a comprar")
      when 'getting_quantity'
        total_amount = paper_order_amount(message_text.to_i)
        if total_amount > find_order_payment.amount
          bot.api.send_message(chat_id: chat_id, text: "No cuenta con saldo para esta operacion")
          find_paper_order.destroy
          clear_step
        else
          markup = Telegram::Bot::Types::ReplyKeyboardMarkup.new(keyboard: back_menu)
          find_paper_order.update(status: 'pending', amount: total_amount, quantity: message_text)
          find_order_payment.update(amount: find_order_payment.amount - total_amount)
          bot.api.send_message(chat_id: chat_id, text: "Su orden para los rollos de papel ha sido creada con exito bajo el id: #{@paper_order.order_id}", reply_markup: markup)
          clear_step
        end
      when 'getting_indicator'
        indicator = MindicadorServices.new(message_text).find_indicators
        indicators << '/Menu'
        markup = Telegram::Bot::Types::ReplyKeyboardMarkup.new(keyboard: indicators)
        bot.api.send_message(chat_id: chat_id, text: indicator, reply_markup: markup)
      end
    end
  end
end
