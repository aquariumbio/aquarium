(function() {
  "use strict";

  let w = angular.module('aquarium');

  /*
   * Provides a manager for cookies that adds a prefix for the session to the name of the cookie.
   */
  w.factory('aqCookieManager', ['$cookies', function($cookies){

    /*
     * The class for the cookie manager.
     *
     */
    class CookieManger {
      constructor(environment_name) {
        this.environment_name = environment_name;
      }

      cookie_name(name) {
        return this.environment_name + "_" + name;
      }

      put_object(name, object) {
        $cookies.putObject(this.cookie_name(name), object);
      }

      get_object(name) {
        return $cookies.getObject(this.cookie_name(name))
      }
    }

    // The factory returns a CookieManager with the environment name set to the global aquarium_environment_name.
    return new CookieManger(aquarium_environment_name);
  } ]);
})();