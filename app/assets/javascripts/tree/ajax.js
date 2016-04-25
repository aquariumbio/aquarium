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

    this.post = function(url,data,f) {
      $http.post(url,data).
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
      this.get('/tree/samples_for_tree.json?project='+project_name+"&sample_type_id="+sample_type_id, 
        function(response) {
          then(response.data);
        });      
    }

    this.subsamples = function(sample,then) {
      this.get('/tree/sub/'+sample.id,function(response) {
        then(response.data);
      });
    }

    this.save_new_samples = function(samples,then) {
      this.post('/tree/save_new',{ new_samples: samples },function(response) {
        then(response.data);
      });
    }

    this.user_info = function(then) {
      var that = this;
      this.get('/users.json',function(users_response) {
        that.get('/users/current',function(current_response) {
          then(users_response.data,current_response.data);
        });
      });
    }

  }]);

})();