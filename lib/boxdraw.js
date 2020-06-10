'use babel';

import { CompositeDisposable } from 'atom';

export default {

  activate(state) {
    // Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    this.subscriptions = new CompositeDisposable();

    // Register command that toggles this view
    this.subscriptions.add(atom.commands.add('atom-workspace', {
      'boxdraw:draw1': () => this.getEndPos(),
      'boxdraw:draw2': () => this.getStartPos()
    }));
  },

  getEndPos() {
    console.log("++++++++++++: ", 111)
  },

  getStartPos() {
    console.log("++++++++++++: ", 222)
  },

  draw() {
    console.log("++++++++++++: ", 333)
  },

  drawWithLabel() {
    console.log("++++++++++++: ", 444)
  },

  select() {
    console.log("++++++++++++: ", 555)
  },

  debug() {
    console.log("++++++++++++: ", 666)
  },

};
