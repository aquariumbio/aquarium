(function () {

  // Set up angular module for aquarium.

  let w = angular.module('aquarium', ['ngCookies', 'ui.ace', 'ngMaterial', 'ngMdIcons', 'ngAnimate']);

  w.config(['$rootScopeProvider', function ($rootScopeProvider) {
    // This is an apparently well known hack that prevents digest errors when recursively
    // rendering templates that nest more than 10 levels.
    $rootScopeProvider.digestTtl(25);
  }]);

  w.config(['$httpProvider', function ($httpProvider) {

    // Changes the CSRF cookie name used by Angular for front-end
    // The variable aquarium_environment_name isn't defined until the site is loaded,
    // so this must be done in an interceptor. If hard-coded could set 
    // $httpProvider.defaults.xsrfCookieName and xsrfHeaderName directly.
    // See ApplicationController for corresponding server-side details
    $httpProvider.interceptors.push(function () {
      return {
        'request': function (config) {
          if (aquarium_environment_name) {
            let cookie_name = 'XSRF-TOKEN_' + aquarium_environment_name;
            config.xsrfCookieName = cookie_name;
            config.xsrfHeaderName = 'X-' + cookie_name;
          }
          return config;
        }
      };
    })
  }]);

  w.factory('csrfInterceptor', ['$q', '$injector', function ($q, $injector) {
    return {
      'responseError': function (rejection) {
        if (rejection.status == 422 && rejection.data == 'Invalid authenticity token') {
          deferred = $q.defer()

          successCallback = function (resp) { deferred.resolve(resp); }
          errorCallback = function (resp) { deferred.reject(resp); }
          $http = $http || $injector.get('$http') // avoids circular dependency
          $http(rejection).config.then(successCallback, errorCallback)
          return deferred.promise
        } else {
          $q.reject(rejection);
        }
      }
    };
  }]);

  w.config(['$httpProvider', function ($httpProvider) {
    $httpProvider.interceptors.push('csrfInterceptor');
  }]);

  w.filter('capitalize', function () {
    return function (input) {
      return (!!input) ? input.charAt(0).toUpperCase() + input.substr(1).toLowerCase() : '';
    }
  });

})();

