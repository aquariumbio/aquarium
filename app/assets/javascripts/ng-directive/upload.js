(function() {

  var w;

  try {
    w = angular.module('aquarium'); 
  } catch (e) {
    w = angular.module('aquarium', ['ngCookies','ui.ace']); 
  } 

  w.directive('customOnChange', function() {
    return {
      restrict: 'A',
      link: function (scope, element, attrs) {
        var onChangeFunc = scope.$eval(attrs.customOnChange);
        element.bind('change', function(event){
          var files = event.target.files;
          onChangeFunc(files);
        });       
        element.bind('click', function(){
          element.val('');
        });
      }
    }
  });

})();
