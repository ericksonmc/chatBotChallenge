class ChatsController < ApplicationController
  before_action :set_chat, only: %i[ show edit update destroy ]

  def index
    @chats = Chat.all

    ActionCable.server.broadcast 'romm_channel', content: 'Hola para ayudarte selecciona una de estas opciones \n /depositos\n /Solcitar Papel \n /Indicadores'
  end

  def show;end

  def new
    @chats = Chat.all 

    @chat = Chat.new 
  end

  def edit;end

  def create
    # type: 0 => Bot
    # type: 1 => Person

    @chat = Chat.new(chat_params)

    respond_to do |format|
      if @chat.save
        ActionCable.server.broadcast 'room_channel', content: {type: 1, message: @chat}
        sleep 1
        if @chat.message.start_with? '/'
          case @chat.message.downcase
          when '/depositos'
            ActionCable.server.broadcast 'room_channel', content: {type: 0, message: {message: 'Indique su Rut seguido de la fecha a consultar ej: 20236734 20/07/2021'}}
          when '/consultas'
          when '/economia'
          else
            ActionCable.server.broadcast 'room_channel', content: {type: 0, message: {message: 'No reconozco esta accion, por favor intentalo nuevamente'}}
          end
        else
          case @chat.message
          when current_user.step
          end
        end
        
        head 200, content_type: 'application/json'
      end
    end
  end

  def update;end

  def destroy
    @chat.destroy
    respond_to do |format|
      format.html { redirect_to chats_url, notice: 'Chat was successfully destroyed.' }
      format.json { head :no_content }
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
    @user ||= User.find_by(rut: params[:chat][:message])
  end
end
