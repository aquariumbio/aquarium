(function() {
  var w = angular.module("aquarium");

  w.controller("importCtrl", [
    "$scope",
    "$http",
    function($scope, $http) {
      AQ.init($http);
      AQ.update = () => {
        $scope.$apply();
      };
      AQ.confirm = msg => {
        return confirm(msg);
      };

      $scope.state = {};

      $scope.options = {
        deploy: false,
        resolution_method: "fail" // or "rename-existing" or "skip"
      };

      $scope.load = function() {
        let file = document.getElementById("import").files[0],
          reader = new FileReader();

        reader.onloadend = function(e) {
          try {
            $scope.importer = new Importer(JSON.parse(e.target.result));
            $scope.state = {};
            $scope.$apply();
          } catch (e) {
            alert("Could not parse file: " + e);
            return;
          }
        };

        reader.readAsText(file); // defaults to UTF-8
      };

      $scope.import = function() {
        $scope.state.importing = true;

        AQ.post("/operation_types/import", {
          operation_types: $scope.importer.content.components,
          options: $scope.options
        })
          .then(response => {
            console.log(response.data);
            $scope.state.import_results = response.data;
            delete $scope.state.importing;
          })
          .catch(response => {
            console.log(response.data);
            $scope.state.import_results = response.data;
            delete $scope.state.importing;
          });
      };
    }
  ]);
})();
