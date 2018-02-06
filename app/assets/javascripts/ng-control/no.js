(function() {

  var w = angular.module('aquarium'); 

  w.controller('noCtrl', [ '$scope', '$http', 
                function (  $scope,   $http ) {

    // For use on pages that need an angular controller to function, but that
    // otherwise don't have any logic. Helps make the aq2.html.erb layout look
    // better.

    AQ.init($http);
    AQ.update = () => { $scope.$apply(); }
    AQ.confirm = (msg) => { return confirm(msg); }

    $scope.status = {};

  }]);

})();                    
