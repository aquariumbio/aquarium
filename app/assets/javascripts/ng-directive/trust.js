(function() {

  var w = angular.module('aquarium'); 

  w.filter("trust", ['$sce', function($sce) {
    return function(htmlCode){
      return $sce.trustAsHtml(htmlCode);
    }
  }]);

})();