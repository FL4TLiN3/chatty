
import {Socket} from "../../../deps/phoenix/web/static/js/phoenix"

Array.prototype.forEach.call(document.querySelectorAll('[data-component]'), node => {
  let socket = new Socket("/socket", {params: {token: window.userToken}})
  socket.connect()

  let channel = socket.channel(node.getAttribute('data-component'), {})
  channel.on("new_msg", payload => {
    node.innerHTML = `${payload.body}`;
  })

  channel.join()
  .receive("ok", resp => {
    console.log("Joined successfully", resp);
    node.innerHTML = resp.html;
  })
  .receive("error", resp => { console.log("Unable to join", resp) })
});

