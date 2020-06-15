'use babel';

import { CompositeDisposable } from 'atom';

const spawn = require('child_process').spawn

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
    
    // let child = spawn('ls', ['-lh', '/usr'])
    let child = spawn('python', ['/Users/d/data/gowww/jkernel/src/github.com/JREAMLU/j-config/nvim/plugged/vim-boxdraw/python/boxdraw.py', '+O', 0, 0, 4, 9, 'abc'])
    child.stdout.on('data', data => {
        console.log("++++++++++++: data ", data)
    });
    child.stderr.on('data', data => {
        console.log("++++++++++++: err ", data)
    });
    // @child.on 'error', (err) => {
    //     console.log("++++++++++++: err stack", err.stack)
    // }
    // @child.stderr.on 'data', (data) =>
    //   console.log("++++++++++++: stderr", data)
    // @child.stdout.on 'data', (data) =>
    //   console.log("++++++++++++: stdout", data)
    // @child.on 'close', (code, signal) =>
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
