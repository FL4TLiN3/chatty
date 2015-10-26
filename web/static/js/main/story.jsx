
import React from 'react';

const Story = React.createClass({
  getInitialState: function () {
    return this.props.story;
  },

  componentWillReceiveProps: function (newProps) {
    this.setState(newProps.story);
  },

  showStory: function () {
    location.href = '/stories/' + this.state.id;
  },

  render: function () {
    let background = {
      'backgroundImage': 'url("' + this.state.cover + '")'
    };

    return (
      <div className="main-story-col-item col-md-6">
        <div className="main-story-wrapper">
          <div className="main-story" style={ background } onClick={ this.showStory }>
            <div className="tag">{ this.state.category.name }</div>
            <div className="info">
              <p className="author">{ this.state.author }</p>
              <p className="title">{ this.state.title }</p>
            </div>
          </div>
        </div>
      </div>
    );
  }
});

export default Story;

