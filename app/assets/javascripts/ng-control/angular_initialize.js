(function() {

  // Set up angular module for aquarium.

  let w = angular.module('aquarium',
          ['ngCookies','ui.ace','ngMaterial','ngMdIcons', 'ngAnimate'], 
          [ '$rootScopeProvider', function($rootScopeProvider) {
      // This is an apparently well known hack that prevents digest errors when recursively
      // rendering templates that nest more than 10 levels.
      $rootScopeProvider.digestTtl(25);
    }]);

  w.filter('capitalize', function() {
      return function(input) {
        return (!!input) ? input.charAt(0).toUpperCase() + input.substr(1).toLowerCase() : '';
      }
  });

})();