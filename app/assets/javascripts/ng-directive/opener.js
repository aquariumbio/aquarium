(function() {

  var w;

  try {
    w = angular.module('aquarium'); 
  } catch (e) {
    w = angular.module('aquarium', ['ngCookies','ui.ace','ngMaterial']); 
  } 

  w.directive("opener", function() {

    return {

      restrict: 'AE',

      scope: { model: '=', invisible: '=', disabled: '=' },

      link: function($scope,$element,$attributes) {

        $scope.toggle = function() {
          if ( !$scope.disabled ) {
            $scope.model = !$scope.model;
          }
        }

      },

      replace: true,

      template: "<span ng-click='toggle()'>" + 
                   "<span class='opener' ng-if='!invisible && !disabled'>" +
                     "{{model ? '&#9660' : '&#9658;'}}" +
                   "</span>" +
                   "<span class='opener-invisible' ng-if='invisible'>&nbsp;</span>" +
                   "<span class='opener' style='color: #bbb; cursor: not-allowed;' ng-if='!invisible && disabled'>&#9658;</span>" +
                 "</span>"

    }

  });
  
})();


//    <!-- <opener class='spanner-cell' style='width: 14px' ng-if="!fv.child_item_id"></span>       -->