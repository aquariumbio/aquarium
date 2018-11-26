(function() {

  var w = angular.module('aquarium'); 

  w.controller('importCtrl', [ '$scope', '$http', 
                function (  $scope,   $http ) {


    AQ.init($http);
    AQ.update = () => { $scope.$apply(); }
    AQ.confirm = (msg) => { return confirm(msg); }

    $scope.state = {};

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

      reader.readAsBinaryString(file);

    }

    $scope.import = function() {

      console.log($scope.importer.content.components)

      AQ.post("/operation_types/import", { operation_types: $scope.importer.content.components })
        .then(response => {
          console.log(response.data);
          $scope.state.import_results = response.data;
        })
        .catch(response => {
          console.log(response.data);
          $scope.state.error = response.data.error;
        });

    }

  }])

})();