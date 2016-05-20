(function() {

  var w;

  try {
    w = angular.module('aquarium'); 
  } catch (e) {
    w = angular.module('aquarium', ['ngCookies']); 
  } 

  w.controller('developerCtrl', [ '$scope', '$http', '$attrs', '$cookies', function ($scope,$http,$attrs,$cookies) {

    $scope.errors = [];
    $scope.messages = [];
    $scope.busy = false;
    $scope.jobs = [];
    $scope.mode = 'edit';
    $scope.arguments = {};

    function add_notice(m) {
      $scope.messages.push({ type: "notice", message: m});
    }

    function add_errors(errors) {
      $scope.messages = $scope.messages.concat(aq.collect(errors,function(e) {
        return { type: "error", message: e }
      }));  
    }

    $scope.get = function() {

      var path = $scope.path;
      $scope.cookie.path = $scope.path;
      $cookies.putObject("developer", $scope.cookie);

      if ( path == "" ) {
        path = "_NOT_SPECIFIED_";
      }

      $scope.busy = true;
      $http.get("/developer/get/" + encodeURIComponent(path))
        .success(function(response) {
          if ( response.errors && response.errors.length > 0 ) {
            add_errors(response.errors);
            $scope.code = "";
          } else {
            $scope.sha = response.sha;
            $scope.code = response.content;
            add_notice("Version " + $scope.sha.substr($scope.sha.length - 7));
          }
          $scope.busy = false;          
        });

    }

    $scope.save = function() {

      if ( confirm("Are you sure you want to save this protocol?" ) ) {

        var path = $scope.path;

        if ( path == "" ) {
          path = "_NOT_SPECIFIED_";
        }

        $scope.busy = true;
        $http.post("/developer/save",{ path: $scope.path, content: $scope.code })
          .success(function(response) {
            if ( response.errors && response.errors.length > 0 ) {
              add_errors(response.errors);
            } else {
              $scope.sha = response.sha;
              add_notice("Saved. New version: " + $scope.sha.substr($scope.sha.length - 7));
            }
            $scope.busy = false;
          });

      }

    }

    $scope.test = function() {

      $scope.busy = true;   
      $scope.backtrace = [];
      $http.post("/developer/test",{ path: $scope.path, arguments: $scope.arguments })
        .success(function(response) {
          if ( response.errors && response.errors.length > 0 ) {
            add_errors(response.errors);
          } else {
            add_notice("Job id: " + response.job.id);
          }
          if ( response.job ) {
            $scope.jobs.unshift(response.job);
            $scope.backtrace = JSON.parse($scope.jobs[0].state);
          }          
          $scope.busy = false;
        });

    }

    $scope.control_class = function(m) {
      if ( m == $scope.mode ) {
        return "dev-control dev-control-on";
      } else {
        return "dev-control";
      }
    }

    $scope.set_mode= function(val) {
      $scope.mode = val;
    }

    $scope.clear_messages = function() {
      $scope.messages = [];
    }

    // Initialize 

    $scope.cookie = $cookies.getObject("developer");

    if ( $scope.cookie && $scope.cookie.path ) {
      $scope.path = $scope.cookie.path;
      $scope.get();
    } else {
      $scope.cookie = { path: "" };
      $cookies.putObject("browserViews", $scope.cookie);
      $scope.path = "";
    }    

    $scope.message_class = function() {
      if ( $scope.messages.length > 0 && $scope.messages[$scope.messages.length-1].type == "error" ) {
        return "dev-control dev-control-error";
      } else {
        return "dev-control";
      }
    }

  }]);

})();