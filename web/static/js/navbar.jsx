
import React from 'react';
import Modal from './ui/modal';
import Login from './login';

const Navbar = React.createClass({
  getInitialState: function () {
    let authorized = false
      , csrfToken;
    Array.prototype.forEach.call(document.getElementsByTagName('meta'), function (meta) {
      if (meta.name == 'tn:login') {
        authorized = true;
      }
      if (meta.name == 'tn:csrf-token') {
        csrfToken = meta.content;
      }
    });
    return {
      authorized: authorized,
      csrfToken: csrfToken
    };
  },

  showLoginModal: function () {
    Modal.show(
      Login,
      { csrfToken: this.state.csrfToken },
      {
        className: 'login',
        top: 100
      }
    );
  },

  render: function () {
    let loginout;
    if (this.state.authorized) {
      loginout = <a href="/logout">Logout</a>;
    } else {
      loginout = <a onClick={ this.showLoginModal }>Login</a>;
    }
    return (
      <nav className="navbar navbar-inverse">
        <div className="container-fluid">
          <div className="navbar-header">
            <button type="button" className="navbar-toggle collapsed" data-toggle="collapse" data-target="#bs-example-navbar-collapse-1" aria-expanded="false">
              <span className="sr-only">Toggle navigation</span>
              <span className="icon-bar"></span>
              <span className="icon-bar"></span>
              <span className="icon-bar"></span>
            </button>
            <a className="navbar-brand logo" href="/"><span className="the">The</span>News</a>
          </div>

          <div className="collapse navbar-collapse" id="bs-example-navbar-collapse-1">
            <ul className="nav navbar-nav navbar-right">
              <li>{ loginout }</li>
            </ul>
          </div>
        </div>
      </nav>
    );
  }
});

export default Navbar;
