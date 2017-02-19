AQ.DataAssociation.record_getters.upload = function() {
  var da = this;
  if ( da._upload ) {
    return da._upload
  } else {
    AQ.Upload.where({id: da.upload_id},{methods: 'url'}).then((uploads) => {
      if ( uploads.length > 0 ) {
        da._upload = uploads[0];
        AQ.update();
      }
    });
  }
}