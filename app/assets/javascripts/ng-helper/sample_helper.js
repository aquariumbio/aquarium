function SampleHelper(http) {
  this.http = http;
}

SampleHelper.prototype.autocomplete = function(promise) {

  this.http.get("/tree/all").then(function(response) {
    promise(response.data);
  });

  return this;
  
}