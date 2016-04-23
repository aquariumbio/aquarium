(function() {

  var w;
  try {
    w = angular.module('tree'); 
  } catch (e) {
    w = angular.module('tree', []); 
  } 

  w.service('treeAjax', [ '$http', function($http) {

    this.get = function(url,f) {
      $http.get(url).
        then(f, function(response) {
          console.log("error: " + response);
        });
    }       

    this.sample_types = function(then) {
      this.get('/sample_types.json', function(response) {
        then(response.data);
      });
    }

    this.samples = function(project_name,sample_type_id,then) {
      this.get('/samples/samples_for_tree.json?project='+project_name+"&sample_type_id="+sample_type_id, function(response) {
        then(response.data);
      });      
    }

    this.subsamples = function(sample,then) {
      this.get('/samples/sub/'+sample.id,function(response) {
        then(response.data)
      });
    }

  }]);

})();