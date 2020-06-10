'use babel';

import { CompositeDisposable } from 'atom';

export default {

  activate(state) {
    // Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    this.subscriptions = new CompositeDisposable();

    // Register command that toggles this view
    this.subscriptions.add(atom.commands.add('atom-workspace', {
      'boxdraw:box-draw': () => this.draw("+o", []),
      'boxdraw:box-draw-label-left': () => this.drawWithLabel("+O", [])
    }));
  },

  getEndPos() {
    console.log("++++++++++++: ", 111)
  },

  getStartPos(startPos) {
    console.log("++++++++++++: ", 222)
  },

  draw(cmd, args) {
    console.log("++++++++++++: ", 333)
  },

  drawWithLabel(cmd, args) {
    console.log("++++++++++++: ", 444)
  },

  select(cmd) {
    console.log("++++++++++++: ", 555)
  },

  debug() {
    console.log("++++++++++++: ", 666)
  },

};
