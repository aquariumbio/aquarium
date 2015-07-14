(function() {

  var w;
  try {
    w = angular.module('workflow'); 
  } catch (e) {
    w = angular.module('workflow', []); 
  }  

  w.directive("alternatives", function() {

    return {
      restrict: 'A',
      scope: { alternatives: "=" },
      templateUrl: "/workflow/editor/alternatives.html"
    }

  });  

  w.directive("alternative", function() {

    return {
      restrict: 'A',
      link: function($scope,$element) {
        if ( $scope.$parent.$parent.disabled() ) {
          $element.find('input').attr('disabled',true);
        }
      }
    }

  });    

  w.directive("ispec", function() {

    return {

      restrict: 'A',
      scope: { ispec: "=", ex: "=", oper: "=", partType: "=" },
      require: "^ngController",
      link: function($scope,$element,$attr,wfCtrl) {

        $scope.disabled = function() {
          return $scope.$parent.$parent.h.operation.workflow != wfCtrl.get_id();
        }

        // Disable if non-native
        if ( $scope.disabled() ) {
          $element.find('input').attr('disabled',true);
          $element.find('textarea').attr('disabled',true);          
        }

        // Dimensions //////////////////////////////////////////////////////////////////////

        $scope.dimensions = function() {
          if ( !$scope.ispec.rows ) {
            $scope.ispec.rows = 1;
          }
          if ( !$scope.ispec.columns ) {
            $scope.ispec.columns = 1;
          }           
        }

        // Alternatives ////////////////////////////////////////////////////////////////////

        $scope.new_alternative = function() {
          $scope.ispec.alternatives.push({});
        }        

        $scope.delete_alternative = function(alternative) {
          aq.delete_from_array($scope.ispec.alternatives,alternative);
        }        

      },

      templateUrl: "/workflow/editor/ispec.html" 

    };                                           

  });    

})();