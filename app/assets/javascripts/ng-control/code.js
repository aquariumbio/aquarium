(function() {

  var w = angular.module('aquarium'); 

  w.controller('codeCtrl', [ '$scope', '$http', '$attrs', '$cookies',
                  function (  $scope,   $http,   $attrs,   $cookies ) {

    $scope.editor = null;

    $scope.aceLoaded = function(_editor) {
      window.dispatchEvent(new Event('resize'));       
      _editor.setShowPrintMargin(false);
      _editor.$blockScrolling = Infinity;  
      $scope.editor = _editor;
      $scope.editor.gotoLine(1); 
    };

    $scope.save = function(code_object,component_name) {
      var controller;
      if ( code_object.model.model === "OperationType" ) {
        controller = "operation_types";
      } else if ( code_object.model.model === "Library" ) {
        controller = "libraries";
      }

      if ( !code_object[component_name].no_edit ) {
        $http.post( "/" + controller + "/code",{
          id: code_object.id,
          name: component_name,
          content: code_object[component_name].content
        }).then(function(response) {
          code_object[component_name] = response.data;
          code_object.recompute_getter('versions')
        });
      }
    }

  }]);

})();                    
