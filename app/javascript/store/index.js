const store = {
  pendingUploads: 0,

  addUpload() {
    this.pendingUploads++;
  },

  removeUpload() {
    this.pendingUploads = Math.max(0, this.pendingUploads - 1);
  },

  hasPendingUploads() {
    return this.pendingUploads > 0;
  }
};

export default store;
