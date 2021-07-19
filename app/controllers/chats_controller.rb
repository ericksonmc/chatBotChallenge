class ChatsController < ApplicationController
  before_action :set_chat, only: %i[ show edit update destroy ]
  before_action :current_user, only: %i[create]

  def index;end

  def new
    @chats = Chat.all 

    @chat = Chat.new 
  end

  def create
    # type: 0 => Bot
    # type: 1 => Person

    @chat = Chat.new(chat_params)

    
    if @chat.save
      ActionCable.server.broadcast 'room_channel', content: {type: 1, message: @chat}
      
      # sleep 1
      if @chat.message.start_with? '/'
        case @chat.message.downcase
        when '/depositos'
          @current_user.to_deposits!
        when '/papel'
          @current_user.to_paper_roll_request!
        when '/economia'
          @current_user.to_economic!
        else
          @current_user.to_menu!
        end
      else
        if @current_user.menu?
          sleep 1
          ActionCable.server.broadcast 'room_channel', content: {type: 0, menu: true, user_id: @current_user.id}
        elsif @current_user.deposits?
          if order_payment.present?
            ActionCable.server.broadcast 'room_channel', content: {type: 0, menu: false, message: { message: "Tiene una orden pendiente de: #{parse_amount(order_payment.amount)}" } }
            @current_user.to_menu!
          else
            ActionCable.server.broadcast 'room_channel', content: {type: 0, menu: false, message: { message: "No Tiene ordenes de pago pendientes" }}
            @current_user.to_menu!
          end
        elsif @current_user.papper?
          @request_order = create_request_order(@chat.message)
          ActionCable.server.broadcast 'room_channel', content: {type: 0, menu: false, message: { message: "Se ha generado una orden de compra de rollos de papel satisfactoriamente, OrderID: #{@request_order.order_id}" }}
          @current_user.to_menu!
        elsif @current_user.economic_indicators?
          if @chat.message&.downcase == 'uf' || @chat.message&.downcase == 'utm'
            @indicator = MindicadorServices.new(@chat.message).find_indicators
            ActionCable.server.broadcast 'room_channel', content: {type: 0, menu: false, message: { message: @indicator }}
          else
            ActionCable.server.broadcast 'room_channel', content: {type: 0, menu: false, message: { message: "Indicador ecnomico incorrecto, opciones: uf, utm. Si desea volver al menu principal /menu" }}
          end
        end
      end
      
      head 200, content_type: 'application/json'
    end
  rescue Exception => e
    if e.to_s.include? 'nil:NilClass'
      reset_chat
    end
  end

  private

  def create_request_order(message)
    rut, address, quantity = message.split('/')
    @paper_request = PaperRequestsServices.new(@current_user, rut, address, quantity).create_paper_request_order
    @paper_request
  end

  def set_chat
    @chat = Chat.find(params[:id])
  end

  def chat_params
    params.require(:chat).permit(:message)
  end

  def current_user
        
    unless params[:user_id].present?
      condition = {}
      @current_user ||= User.find_by(rut: params[:chat][:message].split('/')[1].downcase)
    end
    @current_user ||= User.find_by(id: params[:user_id])
  end

  def order_payment
    date = Date.strptime(@chat.message.split(' ')[1],'%d/%m/%Y')
    @order_payment ||= @current_user.orders.where(status: 'pending', date_to_send: date).last
  end

  def reset_chat
    User.last.to_menu!
  end
end
