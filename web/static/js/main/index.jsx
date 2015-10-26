
import React from 'react';
import {Socket} from "../../../../deps/phoenix/web/static/js/phoenix"

const Main = React.createClass({
  componentDidMount: function () {
    let socket = new Socket("/socket", {params: {token: window.userToken}})
    socket.connect()

    // Now that you are connected, you can join channels with a topic:
    let channel           = socket.channel("rooms:lobby", {})
    let chatInput         = $("#chat-input")
    let messagesContainer = $("#messages")

    chatInput.on("keypress", event => {
      if(event.keyCode === 13){
        channel.push("new_msg", {body: chatInput.val()})
        chatInput.val("")
      }
    })

    channel.on("new_msg", payload => {
      messagesContainer.append(`<br/>[${Date()}] ${payload.body}`)
    })

    channel.join()
    .receive("ok", resp => { console.log("Joined successfully", resp) })
    .receive("error", resp => { console.log("Unable to join", resp) })
  },

  render: function () {
    return (
      <div className="col-md-10 main-stories row">
        <div className="chat">
          <div id="messages"></div>
          <input id="chat-input" type="text"></input>
        </div>
      </div>
    );
  }
});

export default Main;

