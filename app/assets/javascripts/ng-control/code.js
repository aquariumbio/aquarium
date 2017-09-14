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

    $scope.save = function(obj,name) {

      var controller;

      if ( obj.model.model === "OperationType" ) {
        controller = "operation_types";
      } else if ( obj.model.model === "Library" ) {
        controller = "libraries";
      }

      if ( !obj[name].no_edit ) {
        $http.post( "/" + controller + "/code",{
          id: obj.id,
          name: name,
          content: obj[name].content
        }).then(function(response) {
          obj[name] = response.data;
          obj.recompute_getter('versions')
        });
      }
    }

  }]);

})();                    
