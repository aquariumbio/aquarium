AQ.Test = {};


AQ.Test.plan_diff_aux = function (A,B,pkey) {

  // This method is used to recursively check that two plans are equal before and after saving.

  var ignore = [
    '$$hashKey', 'items', 'rid', 'multiselect', '_item', 'ymid_frac', 'xmid_frac', 'updated_at', 'created_at', "_marked"
  ]

  for ( key in A ) {

    if ( A[key] && !ignore.includes(key) && typeof A[key] != 'function' && ( B[key] === undefined  || B[key] === null ) ) {

      console.log([A, A.rid, " defines " + key + " as ", A[key], " but ", B, B.rid, " does not"])

    }  else if ( typeof A[key] == "object" && B[key] ) {

      AQ.Test.plan_diff_aux(A[key], B[key],key)

    } else if ( typeof A[key] != 'function' && !ignore.includes(key) && A[key] != B[key] ) {

      console.log([pkey,A,B,A.rid, B.rid,key,A[key],B[key]])

    }

  }

}

AQ.Test.plan_diff = function (A,B) {

  console.log("---- CHECKING FOR DIFFERENCES BETWEEN PLAN " + A.rid + " AND PLAN " + B.rid + " ----------------" );
  AQ.Test.plan_diff_aux(A,B,"plan");
  console.log("---- DONE CHECKING -----------------------------------------------------------------------------" );

}