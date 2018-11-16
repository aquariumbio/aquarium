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
          $scope.aq_file = new AqFile(JSON.parse(e.target.result));
          $scope.$apply();
        } catch (e) {
          alert("Could not parse file: " + e);
          return;
        }

      };

      reader.readAsBinaryString(file);

    }

  }])

})();