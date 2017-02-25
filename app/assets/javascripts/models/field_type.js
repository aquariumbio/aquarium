AQ.FieldType.record_methods.sample_type_names = function() {
  var ft = this;
  return aq.collect(
           aq.where(ft.allowable_field_types, function(aft) { return aft.sample_type; }),
           function(aft) { return aft.sample_type.name; }
         );
}

AQ.FieldType.record_methods.chosen_sample_type_name = function() {

  var ft = this;

  for ( var i=0; i< ft.allowable_field_types.length; i++ ) {
    if ( ft.allowable_field_types[i].id == ft.aft_choice ) {
      if ( ft.allowable_field_types[i].sample_type ) {
        return ft.allowable_field_types[i].sample_type.name;
      } else {
        return null;
      }
    }
  }

  return null;

}

AQ.FieldType.record_methods.matches = function(field_value) {
  return field_value.role == this.role && field_value.name == this.name;
}

AQ.FieldType.record_methods.can_produce = function(fv) {

  var ft = this,
      rval = false;

  if ( ft.ftype == "sample") {

    if ( fv.field_type.ftype == "sample" ) {

      aq.each(ft.allowable_field_types, (aft) => {
        // console.log([aft.sample_type_id,fv.aft.sample_type_id,aft.object_type.name,fv.aft.object_type.name]);
        if ( fv.aft.sample_type_id == aft.sample_type_id &&
             fv.aft.object_type_id == aft.object_type_id ) {
          // console.log("Found match!")
          rval = true;
        }
      });

    } else { // fv says its a sample, but doesn't specify a sample

      if ( fv.field_type.part ) { // fv is part of an empty collection
        rval = false;
      } else { 
        rval = false;
      }

    }

  } else { // ft does not a produce a sample

    rval = false;

  }

  return rval;

}

  //   case ftype
  //   when "sample"
  //     if fv.child_sample
  //       if fv.object_type
  //         allowable_field_types.each do |aft|
  //           puts "  #{aft.object_type ? aft.object_type.name : '?'} =? #{fv.object_type ? fv.object_type.name : '?'}"
  //           if aft.sample_type && fv.sample_type == aft.sample_type && fv.object_type == aft.object_type            
  //             puts "... yes.\e[39m"
  //             return true
  //           end
  //         end
  //       else
  //         allowable_field_types.each do |aft_from|
  //           fv.field_type.allowable_field_types.each do |aft_to|
  //             puts "  #{aft_from.object_type ? aft_from.object_type.name : '?'} =? #{aft_to.object_type ? aft_to.object_type.name : '?'}"
  //             if aft_from.equals aft_to
  //               puts " ... yes.\e[39m"
  //               return true
  //             end
  //           end
  //         end
  //       end
  //       return false
  //     else # fv says its a sample, but doesn't specify a sample
  //       if fv.field_type.part # fv is part of an empty collection
  //         allowable_field_types.each do |aft|
  //           if !aft.sample_type && fv.object_type == aft.object_type
  //             puts "\e[93m       #{self.name} can produce #{fv.name} \e[39m"
  //             return true
  //           end
  //         end
  //         return false
  //       else
  //         return false
  //       end
  //     end
  //   else # fv is not a sample
  //     return false
  //   end
  // end  

