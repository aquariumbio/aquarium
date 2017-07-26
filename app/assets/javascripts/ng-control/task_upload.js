(function() {

  var w = angular.module('aquarium'); 

  w.controller('taskUploadCtrl', [ '$scope', '$http', '$attrs', '$cookies', 
                        function (  $scope,   $http,   $attrs,   $cookies ) {

    $scope.messages = [];
    $scope.errors = [];
    $scope.tasks = [];
    $scope.task_prototypes = [];    
    $scope.mode = 'upload';
    $scope.offset = 0;
    $scope.current_tp = 0;

    $http.get("/tasks/list/0").then(function(response) {
      $scope.tasks = response.data;
      aq.each($scope.tasks,function(t) {
        t.task_prototype.status_options = JSON.parse(t.task_prototype.status_options)
      });
    })

    $http.get("/task_prototypes.json").then(function(response) {
      $scope.task_prototypes = response.data;
    })    

    $scope.advance = function(n) {
      if ( $scope.offset + n >= 0 ) {
        var temp = $scope.offset;      
        $scope.offset += n;
        $http.get("/tasks/list/" + $scope.offset).then(function(response) {
          if ( response.data.length > 0 ) {
            $scope.tasks = response.data;
            aq.each($scope.tasks,function(t) {
              t.task_prototype.status_options = JSON.parse(t.task_prototype.status_options)
            });            
          } else {
            $scope.offset = temp;
          }
        });
      }
    }

    function upload_tasks(task_data) {
      $http.post("/tasks/upload.json", task_data).then(function(response) {
        if ( response.data.errors.length > 0 ) {
          aq.each(response.data.errors,function(e) { $scope.errors.push(e); });
        } else {
          aq.each(response.data.tasks, function(t) { 
            t.new = true; 
            t.task_prototype.status_options = JSON.parse(t.task_prototype.status_options)            
          });
          $scope.tasks = response.data.tasks.concat($scope.tasks);
          $scope.messages.push("No errors")
        }
      });
    }

    $scope.upload_change = function(files) {
      $scope.tasks_upload_name = files[0].name;
      $scope.upload();      
    }

    $scope.upload = function() {

      $scope.tasks_upload_name = undefined;

      var f = document.getElementById('tasks_upload').files[0],
          r = new FileReader();

      r.onloadend = function(e) {

        var task_data = e.target.result;

        $scope.messages = [];
        $scope.errors = [];

        try {
          var parsed = JSON.parse(task_data);
          $scope.messages.push("JSON ok. Sending '" + f.name + "' to aquarium.");
          upload_tasks(parsed);
        } catch(e) {
          $scope.errors.push("Error: " + e);          
        }       

        $scope.$apply();

      }

      r.readAsBinaryString(f);

    }  

    $scope.change_status = function(task)  {
      $http.get('/update_task_status?task='+task.id+'&status='+task.status).then(function(response) {
        if ( task.status == response.data.task.status ) {
          task.message = "changed status";
        }
      });
    }

  }]);

})();
