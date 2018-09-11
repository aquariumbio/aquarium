AQ.Collection.getter(AQ.ObjectType,"object_type");

AQ.Collection.record_methods.upgrade = function(raw_data) {

  let collection = this,
      m = raw_data.part_matrix;

  if ( m ) {
    for ( var r=0; r<m.length; r++ ) {
      for ( var c = 0; c < m[r].length; c++ ) {
        if ( m[r][c] ) {
          if ( m[r][c].data_associations ) {
            m[r][c].data_associations = aq.collect(m[r][c].data_associations, da => AQ.DataAssociation.record(da))
          }
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

AQ.Collection.new_collection = function(collection_type) {
  return AQ.http.put(`/collections/${collection_type.id}`)
           .then(response => AQ.Collection.record(response.data));
}

// Creates data associations for any parts that don't have a data association named key.
AQ.Collection.record_methods.extend_data_association = function(key) {

  let collection = this;

  aq.each(collection.part_matrix, row => {
    aq.each(row, part => {
      if ( part.record_type == "Item" && !part.has_data_association(key) ) {
        part.new_data_association(key, null);
      } 
    })
  })

}

AQ.Collection.record_methods.save_data_associations = function() {

  let collection = this,
      das = [];

  aq.each(collection.parts, part => {
    aq.each(part.data_associations, da => {
      if ( da.new_value != da.value ) {
        da.set(da.new_value);
        das.push(da);
      }
    })
  })

  return AQ
    .post("/collections/save_data_associations", { data_associations: das })
    .then(result => {
      let updated_das = result.data;
      aq.each(das, da => {
        aq.each(updated_das, updated_da => {
          if ( da.rid == updated_da.rid ) {
            da.id = updated_da.id;
            da.object = updated_da.object;
            da.updated_at = updated_da.updated_at;
            da.recompute_getter('value');
          }
        });
      });
    });

}

AQ.Collection.record_getters.parts = function() {
  let collection = this, part_list = [];
  if ( collection.part_matrix ) {
    aq.each(collection.part_matrix, row => {
      aq.each(row, part => {
        part_list.push(part);
      })
    })
    return part_list;
  } else {
    return [];
  }
}

AQ.Collection.record_getters.data_keys = function() {

  let collection = this,
      keys = [];

  aq.each(collection.part_matrix, row => {
    aq.each(row, part => {
      aq.each(part.data_associations, da => {
        if ( keys.indexOf(da.key) < 0 ) {
          keys.push(da.key);
        }
      })
    })
  })

  delete collection.data_keys;
  collection.data_keys = keys;
  console.log(keys)
  return collection.data_keys;

}

AQ.Collection.find_fast = function(id) {
  return AQ.get(`/collections/${id}`)
           .then(response => AQ.Collection.record(response.data));
}

AQ.Collection.record_getters.part_keys = function() {

  let collection = this,
      keys = [];

  aq.each(collection.part_matrix, row => {
    aq.each(row, element => {
      aq.each(element.data_associations, da => {
        keys.push(da.key);
      })
    })
  })

  return keys;

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
  }).then(response => AQ.Collection.record(response.data));

}

AQ.Collection.record_methods.delete_selection = function() {

  let collection = this;

  return AQ.post(`/collections/${collection.id}/delete_selection`, {
    pairs: collection.selected_pairs
  }).then(response => AQ.Collection.record(response.data));

}