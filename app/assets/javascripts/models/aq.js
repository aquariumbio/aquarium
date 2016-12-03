AQ = {};

AQ.init = function(http) {

  AQ.http = http;
  AQ.get = http.get;
  AQ.post = http.post;

}

AQ.get_sample_names = function() {

  return new Promise(function(resolve,reject) {
    AQ.get('/browser/all').then(
      (response) => {
        AQ.sample_names = response.data;
        resolve();
      }, (response) => {
        reject(response.data.errors);
      }
    );
  });

}

AQ.sample_names_for = function(sample_type_names) {

  var samples = [];
  if ( sample_type_names ) {
    aq.each(sample_type_names,function(type) {
      samples = samples.concat(AQ.sample_names[type])
    });
  }
  return samples;

}