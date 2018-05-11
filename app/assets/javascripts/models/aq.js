AQ = {};

AQ.init = function(http) {

  AQ.http = http;
  AQ.get = http.get;
  AQ.post = http.post;
  AQ.next_record_id = 0;
  AQ.sample_cache = {}; // used by AQ.Sample.find_by_identifier
  AQ.sample_type_cache = {}; // used by AQ.Sample.find_by_identifier

}

AQ.get_sample_names = function() {

  return new Promise(function(resolve,reject) {
    AQ.get('/browser/all').then(
      (response) => {
        AQ.sample_names = response.data;
        resolve(AQ.sample_names);
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

AQ.to_sample_identifier = function(id) {
  var sid = "" + id + ": Name not found. AQ.sample_names may not be loaded";
  for ( var st in AQ.sample_names ) {
    aq.each(AQ.sample_names[st], s => {
      var i = parseInt(s.split(": ")[0]);
      if ( i == id ) {
        sid = s;
      }
    })
  }
  return sid;
}

AQ.id_from = function(sid) { 
  var parts;
  if ( typeof sid == "number" ) {
    return sid;
  } else if ( typeof sid != "string" ) {
    return undefined;
  } else {
    parts = sid.split(": ");
    if ( parts.length > 0 ) {
      var id = parseInt(parts[0]);
      if ( id ) {
        return id
      } else {
        return undefined;
      }
    } else {
      return undefined;
    }
  }
}

AQ.sid_from = function(id) { 
  
}

AQ.items_for = function(sample_id,object_type_id) {

  return new Promise(function(resolve,reject) {

    AQ.post('/json/items/', { sid: sample_id, oid: object_type_id }).then(
      (response) => {
        resolve(aq.collect(response.data, (item) => { 
          if ( item.collection ) {
            var i = item;
            i.collection = AQ.Collection.record(i.collection);
            return new AQ.Record(AQ.Item,item);
          } else {
            return new AQ.Record(AQ.Item,item); 
          }
        }));
      }, (response) => {
        reject(response.data.errors);
      }
    );

  });

}
