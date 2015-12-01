
import co from 'co';

export default class Component {
  constructor (channel, root) {
    this.cname = root.getAttribute('data-component');
    this.channel = channel;
    this.root = root;
    this.cid = `${this.name}:` + ('' + Math.random()).substring(2);
    this._loaded = false;

    co(function* () {
      let result = yield this.channel.push(this, 'initialize', null);
      console.log(result);
      this.patch(result['ops']);
    }.bind(this));
  }

  patch (ops) {
    ops.forEach(op => {
      switch (op.type) {
        case 'insert_node':
          this.insertNode(op.value, op.target); break;
        case 'replace_text':
          this.replaceText(op.value, op.target); break;
      }
    });
  }

  insertNode (html, targetVdomid) {
    let div = document.createElement('div');
    div.innerHTML = html;

    let target;
    if (targetVdomid == null) {
      target = this.root;
    } else {
      target = this.root.querySelector(`[data-vdomid='${targetVdomid}']`);
    }

    Array.prototype.forEach.call(div.childNodes, newNode => {
      target.appendChild(newNode);
    });
  }

  replaceText (text, targetVdomid) {
    let target;
    if (targetVdomid == null) {
      target = this.root;
    } else {
      target = this.root.querySelector(`[data-vdomid='${targetVdomid}']`);
    }

    target.innderHTML = text;
  }

  push (message, payload = {}) {
    return new Promise(resolve => {
      co(function* () {
        payload.name = this.name;

        let result = yield this.channel.push(this, message, payload);
        resolve(result);
      }.bind(this));
    });
  }
}
