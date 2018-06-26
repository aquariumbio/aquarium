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

  var da = this;
  delete da.value;
  da.value = JSON.parse(da.object)[da.key];
  return da.value;

}

AQ.DataAssociation.record_methods.prepare_and_save = function() {

  let da = this,
      temp = {},
      old_object = da.object;

  temp[da.key] = da.new_value;
  da.object = JSON.stringify(temp);

  return da.save();

}