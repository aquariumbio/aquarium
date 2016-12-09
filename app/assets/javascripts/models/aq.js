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

AQ.sample_names_for = function(sample_type_name) {

  var samples = [];
  if ( sample_type_name ) {
    aq.each([sample_type_name],function(type) {
      samples = samples.concat(AQ.sample_names[type])
    });
  }
  return samples;

}

AQ.id_from = function(sid) { 
  return sid.split(":")[0];
}

AQ.items_for = function(sample_id,object_type_id) {

  return new Promise(function(resolve,reject) {

    AQ.get('/json/items/'+sample_id+'/'+object_type_id).then(
      (response) => {
        resolve(aq.collect(response.data, (item) => { return new AQ.Record(AQ.Item,item); }));
      }, (response) => {
        reject(response.data.errors);
      }
    );

  });

}
