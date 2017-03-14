(function() {

  var w;

  try {
    w = angular.module('aquarium'); 
  } catch (e) {
    w = angular.module('aquarium', ['ngCookies','ui.ace','ngMaterial']); 
  } 

  w.directive('modal', function() {
    return {
      restrict: 'A',
      scope: {
        modal: '=',
        title: '='
      },
      replace: true, // Replace with the template below
      transclude: true, // we want to insert custom content inside the directive
      link: function(scope, element, attrs) {
        scope.dialogStyle = {};
        if (attrs.width)
          scope.dialogStyle.width = attrs.width;
        if (attrs.height)
          scope.dialogStyle.height = attrs.height;
        scope.hideModal = function() {
          scope.modal = false;
        };
      },
      template: "<div class='ng-modal' ng-show='modal'>"
              +   "<div class='ng-modal-overlay' ng-click='hideModal()'></div>"
              +   "<div class='ng-modal-dialog' ng-style='dialogStyle'>"
              +       "<div class='ng-modal-title'>{{title}}</div>"                            
              +       "<div class='ng-modal-close' ng-click='hideModal()'>&times;</div>"
              +       "<div class='ng-modal-dialog-content' ng-transclude></div>"
              +   "</div>"
              + "</div>"
    };
  });

  w.filter('bytes', function() {
    return function(bytes, precision) {
      if (isNaN(parseFloat(bytes)) || !isFinite(bytes)) return '-';
      if (typeof precision === 'undefined') precision = 1;
      var units = ['bytes', 'kB', 'MB', 'GB', 'TB', 'PB'],
        number = Math.floor(Math.log(bytes) / Math.log(1024));
      return (bytes / Math.pow(1024, Math.floor(number))).toFixed(precision) +  ' ' + units[number];
    }
  });  

})();