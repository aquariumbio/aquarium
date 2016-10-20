(function() {

  var w;
 
  try {
    w = angular.module('aquarium'); 
  } catch (e) {
    w = angular.module('aquarium', ['ngCookies','ui.ace']); 
  } 

  w.controller('operationTypesCtrl', [ '$scope', '$http', '$attrs', '$cookies', '$sce', 
                            function (  $scope,   $http,   $attrs,   $cookies,   $sce ) {

    $scope.operation_types = [];
    $scope.current_ot = null;
    $scope.user = new User($http);  
    $scope.mode = 'definition';
    $scope.default_protocol = "";
    $scope.categories = [];

    function make_categories() {
      $scope.categories = aq.uniq(aq.collect($scope.operation_types,function(ot) {
        return ot.category;
      }));
    }

    $http.get('/operation_types.json').then(function(response) {
      $scope.operation_types = response.data;
      $scope.current_ot = $scope.operation_types[0];
      make_categories();
    });

    $http.get('/object_types.json').then(function(response) {
      $scope.object_types = response.data;
    });

    $http.get('/sample_types.json').then(function(response) {
      $scope.sample_types = response.data;
    });

    $http.get('/operation_types/default.json').then(function(response) {
      $scope.default_protocol = response.data.content;
    });

    $scope.tab = function(mode) {
      return mode == $scope.mode ? "active" : "";
    }

    $scope.set_mode = function(mode) {
      $scope.mode = mode;
    }

    $scope.choose = function(ot) {
      $scope.current_ot = ot;
      $scope.mode = 'definition';
    }

    $scope.ot_class = function(ot) {
      if ( $scope.current_ot == ot ) {
        return "op-type op-type-current";
      }  else {
        return "op-type";
      }
    }

    $scope.capitalize = function(string) {
      return string.charAt(0).toUpperCase() + string.slice(1);
    }

    $scope.save_ot = function(ot) {
      if ( confirm ( "Are you sure you want to save this operation type definition?" ) ) {
        if ( ot.id ) {
          $http.put("/operation_types/" + ot.id,ot).then(function(response) {
            if ( response.data.errors ) {
              alert ( "Could not update operation type definition: " + response.data.errors.join(", ") )
            } else {
              var i = $scope.operation_types.indexOf(ot);
              $scope.operation_types[i] = response.data;
              $scope.current_ot = response.data;
              make_categories();
            }
          });          
        } else {
          $http.post("/operation_types",ot).then(function(response) {
            var i = $scope.operation_types.indexOf(ot);
            if ( response.data.errors ) {
              alert ( "Could not update operation type definition: " + response.data.errors.join(", ") )
            } else {            
              $scope.operation_types[i] = response.data;            
              $scope.current_ot = response.data;  
              make_categories();
            }
          });
        }
      }
    }

    $scope.delete_ot = function(ot) {
      if ( confirm ( "Are you sure you want delete this operation type definition?" ) ) {

        if ( ot.id ) {

          $http.delete("/operation_types/" + ot.id,ot).then(function(response) {
            if ( response.data.error ) {
              alert ( "Could not delete operation type: " + response.data.error );
            } else {
              var i = $scope.operation_types.indexOf(ot);
              $scope.operation_types.splice(i,1);
              make_categories();
              if ( $scope.operation_types.length > 0 ) {
                $scope.current_ot = $scope.operation_types[0];
              }
            }
          });             

        } else { // ot hasn't been saved yet

          var i = $scope.operation_types.indexOf(ot);
          $scope.operation_types.splice(i,1);
          $scope.current_ot = $scope.operation_types[0];
          make_categories();

        }

      }
    }

    $scope.export_ot = function(ot) {
      $http.get("/operation_types/" + ot.id + "/export").then(function(response) {

        var blob = new Blob([JSON.stringify(response.data)], { type:"application/json;charset=utf-8;" });     
        var downloadLink = angular.element('<a></a>');
                          downloadLink.attr('href',window.URL.createObjectURL(blob));
                          downloadLink.attr('download', ot.name + '.json');
        downloadLink[0].click();

      });
    }

    $scope.import_ot = function() {


      $scope.spreadsheet_name = undefined;

      var f = document.getElementById('import').files[0],
          r = new FileReader();

      r.onloadend = function(e) {

        try {
          var json = JSON.parse(e.target.result);
        } catch(e) {
          alert("Could not parse file: " + e);
          return;
        }

        $http.post("/operation_types/import", { operation_type: json }).then(function(response) {
          if ( !response.data.error ) {
            $scope.current_ot = response.data.operation_type
            $scope.operation_types.push($scope.current_ot);
            make_categories();
          } else {
            alert ( response.data.error );
          }
        });

      }

      r.readAsBinaryString(f);

    }

    $scope.new_operation_type = function() {
      var new_ot = {
        name: "New Operation Type",
        category: "Unsorted",
        deployed: false,
        changed: true,
        field_types:[],
        protocol: { name: 'protocol', content: $scope.default_protocol },
        cost_model: { name: 'cost_model', content: 'def cost(op)\n  { labor: 0, materials: 0 }\nend' },
        documentation: { name: 'documentation', content: "New Operation Type\n===\n\nDocumentation here"}
      };
      $scope.operation_types.push(new_ot);
      $scope.current_ot = new_ot;
      make_categories();
    }

    $scope.render_docs = function(ot) {
      var md = window.markdownit();
      ot.rendered_docs = $sce.trustAsHtml(md.render(ot.documentation.content));
      $scope.mode = 'documentation_view'; 
    }

    $scope.edit_docs = function(ot) {
      $scope.mode = 'documentation';
    }   

    $scope.containers_for = function(sample_name)  {
      return [ sample_name, "Whatever", "Works" ]
    }

    $scope.change = function(thing) {
      thing.changed = true;
    }

    $scope.unchange = function(thing) {
      thing.changed = false;
    }


  }]);

})();
