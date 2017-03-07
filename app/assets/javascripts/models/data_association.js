AQ.DataAssociation.record_getters.upload = function() {

  var da = this;

  delete da.upload;

  AQ.Upload.where({id: da.upload_id},{methods: 'url'}).then((uploads) => {
    if ( uploads.length > 0 ) {
      da.upload = uploads[0];
      AQ.update();
    }
  });

  return {};

}