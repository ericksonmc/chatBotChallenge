import consumer from "./consumer"

consumer.subscriptions.create("RoomChannel", {
  connected() {
    setTimeout(()=>{
      document.getElementById("new_message").insertAdjacentHTML("beforeend",
        `
        <li class='message left appeared'>
          <div class='avatar'></div>
            <div class='text_wrapper'>
              <div class='text'>Para empezar, me envias tu nombre y rut? Ej: Erickson/20236734-A </br>
            </div>
          </div>
        </li>`
      )
    },500)
  },

  disconnected() {
    console.log('desconectando')
    // Called when the subscription has been terminated by the server
  },

  received(data) {
    if(eval(data.content.menu)){
      document.getElementById("new_chat").insertAdjacentHTML('beforeend', `<input type="hidden" name="user_id" value="${data.content.message.user_id}"/>`);
      document.getElementById("new_message").insertAdjacentHTML("beforeend",
      `
      <li class='message left appeared'>
        <div class='avatar'></div>
          <div class='text_wrapper'>
            <div class='text'>He aqui algunas opciones con las que puedo ayudarte: </br>
            <strong>/Depositos</strong> <small>Consulta de depositos</small> </br>
            <strong>/Papel</strong> <small>Solicitud de rollos de papel</small> </br>
            <strong>/Economia</strong> <small>Consulta de Indicadores economicos</small> 
          </div>
        </div>
      </li>`
      )
    }else{
      var type = data.content.type == 0 ? 'left' : 'right';

      var textnode = data.content.message.message;
  
      document.getElementById("new_message").insertAdjacentHTML("beforeend",
        `<li class='message ${type} appeared'><div class='avatar'></div><div class='text_wrapper'><div class='text'>${textnode}</div></div></li>`
      )
  
      document.getElementById('chat_message').value= ''
    }

    var messages = $('.messages');
      messages.animate({ scrollTop: messages.prop('scrollHeight') }, 300);
    // Called when there's incoming data on the websocket for this channel
    
  }
});
