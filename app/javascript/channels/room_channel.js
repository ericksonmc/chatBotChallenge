import consumer from "./consumer"

consumer.subscriptions.create("RoomChannel", {
  connected() {
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
  },

  disconnected() {
    // Called when the subscription has been terminated by the server
  },

  received(data) {
    console.log(data)
    // Called when there's incoming data on the websocket for this channel
    var type = data.content.type == 0 ? 'left' : 'right';

    var textnode = data.content.message.message;

    document.getElementById("new_message").insertAdjacentHTML("beforeend",
      `<li class='message ${type} appeared'><div class='avatar'></div><div class='text_wrapper'><div class='text'>${textnode}</div></div></li>`
    )
    var messages = $('.messages');
    messages.animate({ scrollTop: messages.prop('scrollHeight') }, 300);

    document.getElementById('chat_message').value= ''
  }
});
