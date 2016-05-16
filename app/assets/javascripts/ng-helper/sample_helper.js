function SampleHelper(http) {
  this.http = http;
}

SampleHelper.prototype.autocomplete = function(promise) {

  this.http.get("/browser/all").then(function(response) {
    promise(response.data);
  });

  return this;
  
}

SampleHelper.prototype.samples = function(project,sample_type_id,promise) {

  var sample_helper = this;

  this.http.get('/browser/samples_for_tree.json?project='+project+"&sample_type_id="+sample_type_id)
    .then(function(response) {
      var upgraded_samples = aq.collect(response.data,function(raw_sample) {
        return new Sample(sample_helper.http).from(raw_sample);
      });      
      promise(upgraded_samples);
    });      

  return this;

}

SampleHelper.prototype.recent_samples = function(uid,promise) {

  var sample_helper = this;

  this.http.get('/browser/recent_samples/'+uid)
    .then(function(response) {
      var upgraded_samples = aq.collect(response.data,function(raw_sample) {
        return new Sample(sample_helper.http).from(raw_sample);
      });      
      promise(upgraded_samples);
    });      

  return this;

}

SampleHelper.prototype.create_samples = function(samples,promise) {
  this.http.post('/browser/create_samples', { samples: samples }).then(function(response) {
    promise(response.data);
  });
  return this;
}