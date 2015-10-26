
import React from 'react';
import ReactDOM from 'react-dom';
import pathToRegexp from 'path-to-regexp';

export default class Router {
  constructor (element) {
    this.element = element;
    this.routes = [];
  }

  route (path, fn, opts) {
    this.routes.push({ path: path, fn: fn, opts: opts || {} });
    return this;
  }

  run () {
    for (var i = 0, size = this.routes.length; i < size; i++) {
      let route = this.routes[i]
        , regexp = pathToRegexp(route.path, route.opts)
        , match = regexp.exec(this.getEndpoint());

      if (match) {
        let decode = (val)  => { if (val) return decodeURIComponent(val); }
          , args = match.slice(1).map(decode);

        ReactDOM.render(<route.fn {...args} />, this.element);
        break;
      }
    }
  }

  getEndpoint () {
    return window.location.pathname;
  }
}


