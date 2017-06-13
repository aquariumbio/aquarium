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

AQ.DataAssociation.record_getters.value = function() {

  console.log(da)
  var da = this;
  delete da.value;
  da.value = JSON.parse(da.object)[da.key];
  console.log(da)
  return da.value;

}