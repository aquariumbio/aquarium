
(function() {

  var w;
  try {
    w = angular.module('workflow_editor'); 
  } catch (e) {
    w = angular.module('workflow_editor', []); 
  } 

  w.controller('ispecFormsCtrl', function ($scope,$http) {

    var that = this;
    this.ispec = { rows: 0, columns: 0 };

    $scope.init = function(ispec) {
      $.extend(that.ispec,ispec);
      angular.element().scope().$apply();      
    } 

  }); 

  w.directive("alternative", function() {

    return {

      restrict: 'A',
      scope: { alternative: "=" },
      templateUrl: "/workflow_editor/alternative.html",

      link: function($scope,element,attrs) {

      }

    }

  });

  w.directive("alternatives", function() {

    return {

      restrict: 'A',
      scope: { alternatives: "=" },
      templateUrl: "/workflow_editor/alternatives.html"

    }

  });  

  w.directive("ispec", function() {

    return {

      restrict: 'A',
      scope: { ispec: "=" },
      link: function($scope,element,attrs) {

        // Dimensions //////////////////////////////////////////////////////////////////////

        if ( !$scope.ispec.rows ) {
          $scope.ispec.rows = 1;
        }

        if ( !$scope.ispec.columns ) {
          $scope.ispec.columns = 1;
        }        

        element.find("#scalar").attr('checked',!$scope.ispec.matrix);        
        element.find("#matrix").attr('checked', $scope.ispec.matrix);

        if ( angular.element("#scalar").attr('checked') ) {
          element.find("#dimensions").css('display', 'none');
        }

        $scope.scalar = function() {
          element.find("#dimensions").css('display', 'none');
          $scope.ispec.matrix = false;          
        };

        $scope.matrix = function() {
          element.find("#dimensions").css('display', 'block');
          $scope.ispec.matrix = true;
        }

        $scope.new_alternative = function() {
          $scope.ispec.alternatives.push({});
        }        

        $scope.delete_alternative = function(alternative) {
          aq.delete_from_array($scope.ispec.alternatives,alternative);
        }           

      },

      templateUrl: "/workflow_editor/ispec.html" 

    };                                           

  });  

})();

