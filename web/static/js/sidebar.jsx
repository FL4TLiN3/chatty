
import React from 'react';

const Sidebar = React.createClass({
  render: function () {
    return (
      <div className="col-md-2 visible-md visible-lg sidebar">
        <div className="menu-title"><h3>Menu</h3></div>
        <ul>
          <li><a href="/"><i className="fa fa-comment"></i> Chat</a></li>
        </ul>
      </div>
    );
  }
});

export default Sidebar;
