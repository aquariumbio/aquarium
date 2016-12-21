AQ.Plan.record_methods.submit = function() {

  var plan = this;

  return new Promise(function(resolve,reject) {
    AQ.post('/launcher/submit',plan).then(
      (response) => {
        resolve(AQ.Plan.record(response.data));
      }, (response) => {
        console.log(response.data);
        reject(response.data.errors);
      }
    );
  });

}