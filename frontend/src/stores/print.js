import { defineStore } from 'pinia';

export const usePrintStore = defineStore('print', {
  state: () => ({
    file: null,
    printer: '',
    options: {}
  }),
  actions: {
    setFile(file) {
      this.file = file;
    },
    setPrinter(printer) {
      this.printer = printer;
    },
    setOptions(options) {
      this.options = options;
    }
  }
});
