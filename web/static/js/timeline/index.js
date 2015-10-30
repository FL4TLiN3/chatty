import co from 'co';

export default class TimelineHelper {
  constructor (node, channel) {
    this.node = node;
    this.channel = channel;
    this.fetching = false;
  }

  componentDidMount () {
    let self = this;
    window.addEventListener('scroll', this.scrollListener.bind(this));
    window.addEventListener('resize', this.scrollListener.bind(this));
  }

  scrollListener (target) {
    if (!this.fetching && document.body.offsetHeight - (window.innerHeight + document.body.scrollTop) < 250) {
      co(function* () {
        this.fetching = true;
        yield this.channel.push('older');
        this.fetching = false;
      }.bind(this));
    }
  }
}
