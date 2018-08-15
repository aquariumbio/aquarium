AQ.Collection.getter(AQ.ObjectType,"object_type");

AQ.Collection.record_methods.upgrade = function(raw_data) {

  console.log("here")

  let collection = this,
      m = raw_data.part_matrix_as_json;

  if ( m ) {
    for ( var r=0; r<m.length; r++ ) {
      for ( var c = 0; c < m[r].length; c++ ) {
        if ( m[r][c] ) {
          m[r][c] = AQ.Item.record(m[r][c]);
        } else {
          m[r][c] = {};
        }
      }
    }
  }

  if ( raw_data.object_type ) {
    collection.object_type = AQ.ObjectType.record(raw_data.object_type)
  }

  collection.part_matrix = m;

}

AQ.Collection.record_methods.store = function() {

  var collection = this;

  AQ.get("/items/store/" + collection.id + ".json").then( response => {
    collection.location = response.data.location;
    collection.new_location = response.data.location;
  }).catch( response => {
    alert(response.data.error);
  })

}

AQ.Collection.record_methods.assign_first = function(fv) {

  var r, c;

  for ( r=0; r<this.matrix.length; r++ ) {
    for ( c=0; c<this.matrix[r].length; c++ ) {
      if ( this.matrix[r][c] == fv.child_sample_id ) {
        fv.row = r;
        fv.column = c;
        return fv;
      }
    }
  }

  delete fv.row;
  delete fv.column;

  return fv;

}

AQ.Collection.record_getters.is_collection = function() {
  return true;
}

AQ.Collection.record_getters.selected_pairs = function() {

  let collection = this,
      pairs = [];

  for ( var i=0; i<collection.part_matrix.length; i++ ) {
    for ( var j=0; j<collection.part_matrix[i].length; j++ ) {
      if ( collection.part_matrix[i][j].selected ) {
        pairs.push([i,j])
      }
    }
  }

  return pairs;
}

AQ.Collection.record_methods.assign_sample_to_selection = function(sample_identifier) {

  let collection = this;

  return AQ.post(`/collections/${collection.id}/assign_sample`, {
    sample_id: AQ.id_from(sample_identifier),
    pairs: collection.selected_pairs
  }).then(response => AQ.Collection.record(response.data))

}