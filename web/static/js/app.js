
import {Socket} from "../../../deps/phoenix/web/static/js/phoenix"

import Timeline from "./timeline"

Array.prototype.forEach.call(document.querySelectorAll('[data-component]'), node => {
  let socket = new Socket("/socket", {params: {token: window.userToken}})
  socket.connect()

  let channel = socket.channel(node.getAttribute('data-component'), {})
  channel._push = channel.push;
  channel._pushQueue = [];
  channel.push = function (message, payload) {
    return new Promise(function (resolve) {
      payload = payload || {};
      payload.ts = Date.now();
      var push = channel._push(message, payload);

      channel._pushQueue.push({
        ts: payload.ts,
        message: message,
        payload: payload,
        callback: resolve
      });
    });
  };

  let _module;
  if (node.getAttribute('data-client-helper')) {
    _module = new Timeline(node, channel);
    _module._loaded = false;
  }

  channel
  .on("patch", payload => {
    node.innerHTML = `${payload.html}`;

    channel._pushQueue.forEach(function (push, i) {
      if (push.ts == payload.ts) {
        push.callback && push.callback(payload);
        delete channel._pushQueue[i];
      }
    });
  });

  channel.join()
  .receive("ok", resp => {
    console.log("Joined successfully", resp);

    if (resp.html) {
      node.innerHTML = resp.html;
    }

    if (_module && !_module._loaded) {
      _module.componentDidMount(node, channel);
      _module._loaded = true;
    }
  })
  .receive("error", resp => { console.log("Unable to join", resp) });

});

