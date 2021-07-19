class ChatsController < ApplicationController
  before_action :set_chat, only: %i[ show edit update destroy ]
  before_action :current_user, only: %i[create]

  def index;end

  def new
    @chat = Chat.new 
  end

  def create
    @chat = Chat.new(chat_params)

    
  if @chat.save
    ActionCable.server.broadcast 'room_channel', content: {type: 1, message: @chat}
    
    chat = ChatServices.new(@chat, @current_user)
    chat.send_notification_message
    
    head 200, content_type: 'application/json'
  end
  rescue Exception => e
    if e.to_s.include? 'nil:NilClass'
      reset_chat
    end
  end

  private

  def set_chat
    @chat = Chat.find(params[:id])
  end

  def chat_params
    params.require(:chat).permit(:message)
  end

  def current_user
        
    unless params[:user_id].present?
      @current_user ||= User.find_by(rut: params[:chat][:message].split('/')[1].downcase)
    end
    @current_user ||= User.find_by(id: params[:user_id])
  end

  def reset_chat
    User.last.to_menu!
  end
end
