(function() {

  var w = angular.module('aquarium'); 

  w.config(['ngMdIconServiceProvider', function(ngMdIconServiceProvider) {

    ngMdIconServiceProvider
      .addShapes({

          'input': '<rect x="6" y="6" width="16" height="16" stroke-width="2" fill="none" />' + 
                   '<circle cx="14" cy="6" r="3" stroke-width="2" fill="white"/>',

          'output': '<rect x="6" y="4" width="16" height="16" stroke-width="2" fill="none" />' + 
                   '<circle cx="14" cy="20" r="3" stroke-width="2" fill="white"/>',  

          'module': '<rect x="1" y="3" width="22" height="18" stroke-width="2" fill="none" />' + 
                    '<rect x="8" y="11" width="12" height="6" stroke-width="2" fill="white" />' +
                    '<rect x="4" y="7" width="12" height="6" stroke-width="2" fill="white" />'  
                                                 
      });
  }]);

})();