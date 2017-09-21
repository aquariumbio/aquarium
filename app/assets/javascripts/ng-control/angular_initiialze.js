(function() {

  // Set up angular module for aquarium.

  let w = angular.module('aquarium',
          ['ngCookies','ui.ace','ngMaterial','ngMdIcons', 'ngAnimate'], 
          [ '$rootScopeProvider', '$httpProvider', function($rootScopeProvider, $httpProvider) {
      // This is an apparently well known hack that prevents digest errors when recursively
      // rendering templates that nest more than 10 levels.
      $rootScopeProvider.digestTtl(25);

      // Changes the CSRF cookie name used by Angular for front-end
      // Requires corresponding change for back-end
      $httpProvider.interceptors.push(function(){
        return {
          'request': function(config) {
            let cookie_name = 'XSRF-TOKEN_' + aquarium_environment_name;
            config['xsrfCookieName'] = cookie_name;
            config['xsrfHeaderName'] = 'X-' + cookie_name;
            return config;
          }
        };
      } )
    }]);

  w.filter('capitalize', function() {
      return function(input) {
        return (!!input) ? input.charAt(0).toUpperCase() + input.substr(1).toLowerCase() : '';
      }
  });

})();