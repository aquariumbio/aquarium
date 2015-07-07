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

  w.directive("ispec", function() {

    return {

      restrict: 'A',
      scope: { ispec: "=", opName: "=", opType: "=" },
      link: function($scope,$element,$attr) {

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