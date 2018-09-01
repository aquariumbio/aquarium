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

AQ.DataAssociation.record_methods.set = function(value) {

  let da = this,
      temp = {};

  temp[da.key] = value;
  da.object = JSON.stringify(temp);
  da.new_value = value;
  return da;

}

AQ.DataAssociation.record_getters.value = function() {

  var da = this;
  delete da.value;
  da.value = JSON.parse(da.object)[da.key];
  return da.value;

}

AQ.DataAssociation.record_getters.new_value = function() {

  var da = this;
  delete da.new_value;
  da.new_value = da.value;
  return da.new_value;

}


AQ.DataAssociation.record_methods.prepare_and_save = function() {

  let da = this,
      temp = {};

  temp[da.key] = da.new_value;
  da.object = JSON.stringify(temp);

  return da.save();

}

AQ.DataAssociation.base_methods = {

  data_association: function(key) {
    var record = this,
        da = null;
    aq.each(record.data_associations, da => {
      if ( da.key == key ) {
        rval = da;
      }
    })
    return rval;
  },  

  has_data_association: function(key) {
    var record = this,
        rval = false;
    aq.each(record.data_associations, da => {
      if ( da.key == key ) {
        rval = true;
      }
    })
    return rval;
  },

  new_data_association: function(key, value) {

    let record = this,
        da,
        temp = {};

    temp[key] = value;
    da = AQ.DataAssociation.record({
      key: key ? key : 'key', 
      object: JSON.stringify(temp),
      parent_class: record.record_type,
      parent_id: record.id,
      unsaved: true
    })

    return da;

  }

}

AQ.DataAssociation.base_getters = {

  data_associations: function() {

    var record = this;
    delete record.data_associations;

    AQ.DataAssociation.where({parent_id: record.id, parent_class: record.model.model}).then((das) => {          
      record.data_associations = das;
      aq.each(record.data_associations,(da) => {
        da.value = JSON.parse(da.object)[da.key];
        da.upload = AQ.Upload.record(da.upload)
      });
      AQ.update();   
    });

    return null;

  }

}