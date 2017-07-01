AQ.Upload.record_methods.get_expiring_url = function() {
  var upload = this;
  return new Promise(function(resolve,reject) {
    AQ.Upload.where({id: upload.id}, { methods: [ "expiring_url" ] }).then(uploads => {
      if ( uploads.length == 1 ) {
        resolve(uploads[0].expiring_url);
      }
    });
  });
}