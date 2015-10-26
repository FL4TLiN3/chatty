
import React from 'react';
import ReactDOM from 'react-dom';

const ModalInterface = React.createClass({
  componentDidMount: function () {
    $('#modal').modal();
    if (this.props.options.top) $('#modal').css('padding-top', this.props.options.top + 'px');
    $('#modal').on('hide.bs.modal', function (e) {
      this.unmountModal(true);
    }.bind(this));
  },

  unmountModal: function (hiding) {
    if (!hiding) {
      $('#modal').modal('hide');
      return;
    }
    ReactDOM.unmountComponentAtNode(document.getElementById('modal-target'));
  },

  showIndicator: function () {
    ReactDOM.render(<LoadingIndicator />, document.getElementById('modal-indicator'));
  },

  hideIndicator: function () {
    ReactDOM.unmountComponentAtNode(document.getElementById('modal-indicator'));
  },

  render: function () {
    let arrow;
    if (this.props.options.arrow) {
      arrow = <div className="arrow"></div>;
    }

    return (
      <div id='modal' className={ 'modal ' + this.props.options.className } role="dialog">
        { arrow }
        <div className="modal-dialog" role="document">
            <this.props.component ref="modal-content" { ...this.props.componentProps } />
        </div>
      </div>
    );
  }
});

const LoadingIndicator = React.createClass({
  render: function() {
    return <i className="fa fa-spinner fa-pulse"></i>;
  }
});

class Modal {
  constructor () {
    this.modal = null;
  }

  show (component, componentProps, options) {
    componentProps = componentProps || [];
    options = options || {};
    this.modal = ReactDOM.render(
      <ModalInterface component={ component } componentProps={ componentProps } options={ options } />,
      document.getElementById('modal-target')
    );
  }

  hide () {
    this.modal.unmountModal();
  }

  showIndicator () {
    this.modal.showIndicator();
  };

  hideIndicator () {
    this.modal.hideIndicator();
  };
}

if (Object.keys(module.exports).length == 0) {
  module.exports = new Modal();
}
