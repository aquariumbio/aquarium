(function() {

  var w;
 
  try {
    w = angular.module('aquarium'); 
  } catch (e) {
    w = angular.module('aquarium', ['ngCookies','ui.ace','ngMaterial']); 
  } 

  w.controller('userCtrl', [ '$scope', '$http', '$attrs', '$cookies', '$sce', 
                  function (  $scope,   $http,   $attrs,   $cookies,   $sce ) {

    var user_id = window.location.href.split('/').pop();

    AQ.init($http);
    AQ.update = () => { $scope.$apply(); }
    AQ.confirm = (msg) => { return confirm(msg); }
    AQ.sce = $sce;

    $scope.views = [  "Information", "Preferences", "Memberships", "Change Password", "Budgets",
                      "BIOFAB Agreement", "Aquarium Agreement" ];    

    $scope.preferences = [
      {
        name: "Make new samples private",
        type: "boolean"
      },
      {
        name: "Lab Name",
        type: "string"
      }         
    ];

    $scope.status = {
      view: "Information",
      password_ok: true
    };

    $scope.check_password = function() {

      if ( $scope.user.password ) {
        $scope.status.password_ok = $scope.user.password == $scope.user.password_confirmation && $scope.user.password.length >= 10;
      } else {
        $scope.status.password_ok = true;
      }

    }
    
    $scope.reload = function() {

      AQ.User.find(user_id).then(user => {
        $scope.user = user;
        $scope.user.init_params(['email', 'phone']);
        $scope.user.init_params(aq.collect($scope.preferences, p => p.name));
        $scope.user.recompute_getter('parameters');
        AQ.User.current().then(user => {
          $scope.current_user = user;
          AQ.update();        
        })
      });

    }

    $scope.reload();

  }]);

})();