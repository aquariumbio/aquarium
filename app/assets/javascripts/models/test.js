AQ.Test = {};

AQ.Test.plan_diff_aux = function (A,B,pkey) {

  // This method is used to recursively check that two plans are equal before and after saving.

  var ignore = [
    '$$hashKey', 'items', 'rid', 'multiselect', '_item', 'ymid_frac', 'xmid_frac', 'updated_at', 'created_at', 
    '_marked', 'test', 'cost', 'estimating', 'drag', 'uba', 'errors', 'sample', 
    'next_module_id', 'inputs', 'outputs', 'current_module', "from_module", "to_module", "module_list"
  ];

  if ( AQ.Test.num_calls < 100 ) {

    for ( key in A ) {

      if ( A[key] && A[key] != [] && !ignore.includes(key) && typeof A[key] != 'function' && ( B[key] === undefined  || B[key] === null ) ) {

        console.log([A, A.rid, " defines " + key + " as ", A[key], " but ", B, B.rid, " does not"])

      }  else if ( typeof A[key] == "object" && B[key] && !ignore.includes(key) ) {

        AQ.Test.plan_diff_aux(A[key], B[key],key)

      } else if ( typeof A[key] != 'function' && !ignore.includes(key) && A[key] != B[key] ) {

        console.log([key,A,B,A.rid, B.rid,key,A[key],B[key]])

      }

    }

    AQ.Test.num_calls++;

  }

}

AQ.Test.plan_diff = function (A,B) {

  console.log("---- CHECKING FOR DIFFERENCES BETWEEN BEFORE AND AFTER SAVING---------------" );
  AQ.Test.num_calls = 0;
  AQ.Test.plan_diff_aux(A,B,"plan");
  console.log("---- DONE CHECKING ---------------------------------------------------------" );

}