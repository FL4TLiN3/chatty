
import co from 'co';
import {Socket} from "../../../deps/phoenix/web/static/js/phoenix"

import Navbar from "./navbar"
import Sidebar from "./sidebar"
import Timeline from "./timeline"

let components = {
  'Navbar': Navbar,
  'Sidebar': Sidebar,
  'Timeline': Timeline
};

const connect = function () {
  return new Promise(function (resolve) {

    let socket = new Socket("/socket");
    socket.connect();

    let channel = socket.channel('ashes', {});
    channel
    .join()
    .receive("ok", resp => {
      console.log("Ashes Joined Successfully");

      channel._push = channel.push;
      channel._pushQueue = [];
      channel.push = function (component, message, payload) {
        return new Promise(function (_resolve) {
          payload = payload || {};
          payload.ts = Date.now();
          payload.cid = component.cid;
          payload.cname = component.cname;

          var push = channel._push(message, payload);

          channel._pushQueue.push({
            cid: component.cid,
            ts: payload.ts,
            message: message,
            payload: payload,
            callback: _resolve
          });
        });
      };

      channel
      .on("noop", payload => {
        channel._pushQueue.forEach(function (push, i) {
          if (push.cid == payload.cid && push.ts == payload.ts) {
            delete channel._pushQueue[i];
          }
        });
      });

      channel
      .on("patch", payload => {
        channel._pushQueue.forEach(function (push, i) {
          if (push.cid == payload.cid && push.ts == payload.ts) {
            push.callback && push.callback(payload);
            delete channel._pushQueue[i];
          }
        });
      });

      resolve(channel);
    })
    .receive("error", resp => {
      console.log("Unable to join", resp);
      resolve(null);
    });
  });
};

co(function* () {
  let channel = yield connect();

  Array.prototype.forEach.call(document.querySelectorAll('[data-component]'), node => {
    let componentName = node.getAttribute('data-component');
    let component = new components[componentName](channel, node);

    component._loaded = false;

    if (component && !component._loaded) {
      if (component.componentDidMount) component.componentDidMount(node, channel);
      component._loaded = true;
    }
  });
});


