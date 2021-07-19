class ChatServices
  def initialize(chat, current_user)
    @chat = chat
    @current_user = current_user
  end
  
  def send_notification_message
    if @chat.message.start_with? '/'
      state_machin_transition
    else
      chat_actions
    end
  end

  private

  def state_machin_transition
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
  end

  def chat_actions
    if @current_user.menu?
      broadcast_action(menu: true, message: { user_id: @current_user.id })
    elsif @current_user.deposits?
      byebug
      if order_payment.present?
        broadcast_action(message: { message: I18n.t(:have_order, amount: order_payment.amount) })
        @current_user.to_menu!
      else
        broadcast_action(message: { message: I18n.t(:not_orders) })
        @current_user.to_menu!
      end
    elsif @current_user.papper?
      @request_order = create_request_order(@chat.message)
      broadcast_action(message: { message: I18n.t(:generated_order, order_id: @request_order.order_id) })
      @current_user.to_menu!
    elsif @current_user.economic_indicators?
      if @chat.message&.downcase == 'uf' || @chat.message&.downcase == 'utm'
        @indicator = MindicadorServices.new(@chat.message).find_indicators
        broadcast_action(message: { message: @indicator })
      else
        broadcast_action(message: { message: I18n.t(:question_indicator) })
      end
    end
  end

  def broadcast_action(menu: false, message: {}, current_user: nil)
    ActionCable.server.broadcast 'room_channel', content: { type: 0, menu: menu, message: message }
  end

  def order_payment
    date = Date.strptime(@chat.message.split(' ')[1],'%d/%m/%Y')
    @order_payment ||= @current_user.orders.where(status: 'pending', date_to_send: date).last
  end

  def create_request_order(message)
    rut, address, quantity = message.split('/')
    @paper_request = PaperRequestsServices.new(@current_user, rut, address, quantity).create_paper_request_order
    @paper_request
  end
end