
import React from 'react';

const Sidebar = React.createClass({
  render: function () {
    return (
      <div className="col-md-2 visible-md visible-lg sidebar">
        <div className="menu-title"><h3>Categories</h3></div>
        <ul>
          <li><a href="/stories?category=trend"><i className="fa fa-rocket"></i> Trend</a></li>
          <li><a href="/stories?category=travel"><i className="fa fa-plane"></i> Travel</a></li>
          <li><a href="/stories?category=culture"><i className="fa fa-paint-brush"></i> Culture</a></li>
        </ul>
      </div>
    );
  }
});

export default Sidebar;
