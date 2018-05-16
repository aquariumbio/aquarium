(function() {

  var w = angular.module('aquarium'); 

  w.directive("oplist", ['$mdDialog', function($mdDialog) {

    return {
      restrict: 'E',
      scope: { operations: '=', status: '=', operationtype: '=', jobid: '=' },
      replace: true,
      template: $('#operation-list').html(),
      link: function($scope) {
        $scope.change_status = function(operation, status) {

          let confirm = $mdDialog.confirm()
              .title('Change Operation Status:')
              .textContent(`Do you really want to change the status of operation ${operation.id} to ${status}?`)
              .ariaLabel('Change Status')
              .ok('Yes')
              .cancel('No');

          $mdDialog.show(confirm).then(() => {
            operation.set_status(status);
            window.location = '/operations'
          });

        }        
      }
    }

  }]);

  w.directive("oplistShort", function() {

    return {
      restrict: 'E',
      scope: { operations: '=', status: '=', operationtype: '=', jobid: '=' },
      replace: true,
      template: $('#operation-list-short').html(),
      link: function($scope,$element,$attributes) {

        $scope.open_item_ui = function(id) {
          open_item_ui(id);
        }

      }      
    }

  });  

})();