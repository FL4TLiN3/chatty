import co from 'co';
import Component from './component'

export default class Timeline extends Component {
  constructor (channel, node) {
    super(channel, node);
    this.fetching = false;
  }

  componentDidMount () {
    window.addEventListener('scroll', this.scrollListener.bind(this));
    this.fetchData('older');
  }

  scrollListener (target) {
    if (!this.fetching && document.body.offsetHeight - (window.innerHeight + document.body.scrollTop) < 50) {
      this.fetchData('older');
    }
  }

  fetchData (direction) {
    co(function* () {
      this.fetching = true;
      let result = yield this.push(direction);
      this.patch(result.ops);
      this.fetching = false;
    }.bind(this));
  }
}
