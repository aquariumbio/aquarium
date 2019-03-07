(function() {

  var w = angular.module('aquarium');

  w.controller('logCtrl', [ '$scope', '$http',
                function  (  $scope,   $http ) {

    AQ.init($http);
    AQ.update = () => { $scope.$apply(); }
    AQ.confirm = (msg) => { return confirm(msg); }

    $scope.status = {};
    AQ.Job
      .find(parseInt(aq.query().job))
      .then(job => $scope.job = job );

    $scope.open_item_ui = function(id) {
      AQ.Item.where({id: id}, { include: ["object_type", "sample"]}).then(items => {
        if ( items.length > 0 ) {          
          $scope.item = items[0];
          $scope.item.modal = true;
          $scope.$apply();
        } else {
          alert("Item " + id + " not found.")
        }
      });
    }

  }]);

})();
