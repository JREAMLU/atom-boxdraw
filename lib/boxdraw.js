'use babel';

import BoxdrawView from './boxdraw-view';
import { CompositeDisposable } from 'atom';

export default {

  boxdrawView: null,
  modalPanel: null,
  subscriptions: null,

  activate(state) {
    this.boxdrawView = new BoxdrawView(state.boxdrawViewState);
    this.modalPanel = atom.workspace.addModalPanel({
      item: this.boxdrawView.getElement(),
      visible: false
    });

    // Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    this.subscriptions = new CompositeDisposable();

    // Register command that toggles this view
    this.subscriptions.add(atom.commands.add('atom-workspace', {
      'boxdraw:toggle': () => this.toggle()
    }));
  },

  deactivate() {
    this.modalPanel.destroy();
    this.subscriptions.dispose();
    this.boxdrawView.destroy();
  },

  serialize() {
    return {
      boxdrawViewState: this.boxdrawView.serialize()
    };
  },

  toggle() {
    console.log('Boxdraw was toggled!');
    return (
      this.modalPanel.isVisible() ?
      this.modalPanel.hide() :
      this.modalPanel.show()
    );
  }

};
