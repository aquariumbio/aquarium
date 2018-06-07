(function() {

  var w = angular.module('aquarium'); 

  w.controller('wizardCtrl', [ '$scope', '$http', 
                function (  $scope,   $http ) {

    // For use on pages that need an angular controller to function, but that
    // otherwise don't have any logic. Helps make the aq2.html.erb layout look
    // better.

    AQ.init($http);
    AQ.update = () => { $scope.$apply(); }
    AQ.confirm = (msg) => { return confirm(msg); }

    $scope.status = {};

    let box = aq.url_params().box;
    let id = parseInt(aq.url_path()[2]);

    AQ.http.get(`/wizards/contents/${id}?box=${box}`).then(response => {
      $scope.contents = aq.collect(response.data, i => AQ.Locator.record(i));
      console.log($scope.contents)
    })

  }]);

})();                    
