class AqTest {

  constructor() {

    let aq_test = this;
    aq_test.tests = { path: "", its: [] };
    aq_test.current = aq_test.tests;

  }

  run() {
    let aq_test = this;
    aq_test.current = aq_test.tests;
    aq_test.run_aux(aq_test.current);
  }

  run_aux(tests) {

    for ( var i=0; i<tests.its.length; i++ ) {
      tests.its[i].results = [];
      if ( tests.its[i].method ) {  
        try {
          tests.its[i].method(aq_test.make_done_doer(tests.its[i]));
        } catch(e) {
          tests.its[i].results.push("failed");
          tests.its[i].results.push(e);
          console.log(tests.its[i].path + ":" + tests.its[i].description + ": " +  e)
        }
      } else {
        tests.its[i].results.push("unimplemented")
      }
    }

    for ( var sub in tests ) {
      if ( sub != 'its' && sub != 'path' ) {
        aq_test.run_aux(tests[sub])
      }
    }

  }

  make_done_doer(it) {
    return function(err) {
      if ( err ) {
        console.log(it.path + ":" + it.description + ": " +  err.stack)
        it.results.push(err)
      } else {
        it.results.push("done");
      }
    }
  }

}

aq_test = new AqTest();

function describe(name, method) {
  let temp = aq_test.current;
  if ( name == "its" || name == "path" ) {
    raise("You can't call a test description 'its' or 'path'");
  }
  aq_test.current[name] = {
    path: aq_test.current.path + "/" + name, 
    its: [] 
  };
  aq_test.current = aq_test.current[name];
  method();
  aq_test.current = temp;
}

function it(description, method) {
  aq_test.current.its.push({
    path: aq_test.current.path,
    description: description,
    method: method
  })
}