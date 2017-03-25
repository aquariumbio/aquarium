(function() {

  var w;
 
  try {
    w = angular.module('aquarium'); 
  } catch (e) {
    w = angular.module('aquarium', ['ngCookies','ui.ace','ngMaterial']); 
  } 

  w.controller('operationTypesCtrl', [ '$scope', '$http', '$attrs', '$cookies', '$sce', 
                            function (  $scope,   $http,   $attrs,   $cookies,   $sce ) {

    AQ.init($http);
    AQ.update = () => { $scope.$apply(); }
    AQ.confirm = (msg) => { return confirm(msg); }

    $scope.operation_types = [];
    $scope.current_ot = null;
    $scope.user = new User($http);  

    if ( $cookies.getObject("DeveloperMode") ) {
      $scope.mode = $cookies.getObject("DeveloperMode");
    } else {
      $scope.mode = 'definition';
    }

    $scope.default_protocol = "";
    $scope.categories = [];
    $scope.initialized = false;

    function make_categories() {
      $scope.categories = aq.uniq(aq.collect($scope.operation_types,function(ot) {
        return ot.category;
      })).sort();
      if ( $cookies.getObject("DeveloperCurrentCategory") ) {
        $scope.choose_category($cookies.getObject("DeveloperCurrentCategory"));
      } else if ( $scope.categories.length > 0 && !$scope.current_category ) {
        $scope.choose_category($scope.categories[0]);
      }
    }

    AQ.OperationType.all().then(operation_types => {
      $scope.operation_types = operation_types;
      if ( $cookies.getObject("DeveloperCurrentOperationTypeId") ) {
        var ots = aq.where($scope.operation_types,ot => ot.id == $cookies.getObject("DeveloperCurrentOperationTypeId") );
        if  ( ots.length == 1 ) {
          $scope.current_ot = ots[0];
        } else {
          $scope.current_ot = $scope.operation_types[0];         
        }
      } else {
        $scope.current_ot = $scope.operation_types[0];
      }
      make_categories();
      $scope.initialized = true;      
    });

    // $http.get('/operation_types.json').then(function(response) {
    //   $scope.operation_types = response.data;
    //   if ( $cookies.getObject("DeveloperCurrentOperationTypeId") ) {
    //     var ots = aq.where($scope.operation_types,ot => ot.id == $cookies.getObject("DeveloperCurrentOperationTypeId") );
    //     if  ( ots.length == 1 ) {
    //       $scope.current_ot = ots[0];
    //     } else {
    //       $scope.current_ot = $scope.operation_types[0];         
    //     }
    //   } else {
    //     $scope.current_ot = $scope.operation_types[0];
    //   }
    //   make_categories();
    //   $scope.initialized = true;
    // });

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
      $cookies.putObject("DeveloperMode",mode) 
      $scope.mode = mode;
    }

    $scope.choose = function(ot) {
      $scope.current_ot = ot;
      $scope.mode = 'definition';
      $cookies.putObject("DeveloperCurrentOperationTypeId", ot.id); 
    }

    $scope.choose_category = function(c) {
      if ( $scope.current_category == c ) {
        delete $scope.current_category;
      } else {
        $scope.current_category = c;
        $cookies.putObject("DeveloperCurrentCategory", c);        
      }
    }

    $scope.category_size = function(c) {
      return aq.where($scope.operation_types,function(ot) { return ot.category == c; }).length;
    }    

    $scope.ot_class = function(ot) {
      var c = "op-type";
      if ( $scope.current_ot == ot ) {
        c += " op-type-current";
      } 
      if ( ot.deployed ) {
        c += " op-type-deployed"
      }
      return c;
    }

    $scope.capitalize = function(string) {
      return string.charAt(0).toUpperCase() + string.slice(1);
    }

    $scope.save_ot = function(ot) {
      if ( confirm ( "Are you sure you want to save this operation type definition?" ) ) {
        if ( ot.id ) {
          $http.put("/operation_types/" + ot.id,ot).then(function(response) {
            if ( response.data.errors ) {
              alert ( "Could not update operation type definition: " + response.data.errors[0] )
              console.log(response.data.errors);
            } else {
              var i = $scope.operation_types.indexOf(ot);
              $scope.operation_types[i] = response.data;
              $scope.current_ot = response.data;
              make_categories();
              $scope.current_category = $scope.current_ot.category;
              $cookies.putObject("DeveloperCurrentCategory", $scope.current_ot.category);        
            }
          });          
        } else {
          $http.post("/operation_types",ot).then(function(response) {
            var i = $scope.operation_types.indexOf(ot);
            if ( response.data.errors ) {
              alert ( "Could not update operation type definition: " + response.data.errors[0] );
              console.log(response.data);
            } else {            
              $scope.operation_types[i] = response.data;            
              $scope.current_ot = response.data;  
              make_categories();
              $scope.current_category = $scope.current_ot.category;
              $cookies.putObject("DeveloperCurrentOperationTypeId", $scope.current_ot.id);
              $cookies.putObject("DeveloperCurrentCategory", $scope.current_ot.category);                
            }
          });
        }
      }
    }

    function after_delete(c) {
      make_categories();
      if ( $scope.category_size(c) > 0 ) {
        var ots = aq.where($scope.operation_types, ot => ot.category == c );
        $scope.current_ot = ots[0];
        $cookies.putObject("DeveloperCurrentOperationTypeId", $scope.current_ot.id); 
        $scope.current_category = c;
        $cookies.putObject("DeveloperCurrentCategory", c);          
      } else if ( $scope.operation_types.length > 0 ) {
        $scope.current_ot = $scope.operation_types[0];
        $cookies.putObject("DeveloperCurrentOperationTypeId", $scope.current_ot.id); 
        $scope.current_category = $scope.current_ot.category;
        $cookies.putObject("DeveloperCurrentCategory", $scope.current_ot.category);                 
      }      
    }

    $scope.delete_ot = function(ot) {
      if ( confirm ( "Are you sure you want delete this operation type definition?" ) ) {

        if ( ot.id ) {

          $http.delete("/operation_types/" + ot.id,ot).then(function(response) {
            if ( response.data.error ) {
              alert ( "Could not delete operation type: " + response.data.error );
            } else {
              var i = $scope.operation_types.indexOf(ot),
                  c = ot.category;
              $scope.operation_types.splice(i,1);
              after_delete(c);
            }
          });             

        } else { // ot hasn't been saved yet

          var i = $scope.operation_types.indexOf(ot),
              c = ot.category;
          $scope.operation_types.splice(i,1);
          after_delete(c);          
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

    $scope.export_category = function(category) {
      $http.get("/operation_types/export_category/" + category).then(function(response) {

        var blob = new Blob([JSON.stringify(response.data)], { type:"application/json;charset=utf-8;" });     
        var downloadLink = angular.element('<a></a>');
                          downloadLink.attr('href',window.URL.createObjectURL(blob));
                          downloadLink.attr('download', category + '.json');
        downloadLink[0].click();

      });
    }

    $scope.import = function() {

      var f = document.getElementById('import').files[0],
          r = new FileReader();

      r.onloadend = function(e) {

        try {
          var json = JSON.parse(e.target.result);
        } catch(e) {
          alert("Could not parse file: " + e);
          return;
        }

        $http.post("/operation_types/import", { operation_types: json }).then(function(response) {
          if ( !response.data.error ) {
            if ( response.data.operation_types.length > 0 ) {
              $scope.operation_types = $scope.operation_types.concat(response.data.operation_types);
              aq.each(response.data.operation_types,o => console.log(o.category))
              make_categories();
              $scope.current_ot = response.data.operation_types[0];     
              $scope.current_category = $scope.current_ot.category;         
            } else {
              alert ( "No operation types found in file." );
            }
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
        precondition: { name: 'precondition', content: 'def precondition(op)\n  true\nend'},
        documentation: { name: 'documentation', content: "New Operation Type\n===\n\nDocumentation here"}
      };
      $scope.operation_types.push(new_ot);
      $scope.current_ot = new_ot;
      make_categories();
      $scope.current_category = "Unsorted";
      $scope.mode = "definition";
    }

    $scope.copy = function(ot) {

      $http.get("/operation_types/" + ot.id + "/copy/").then(function(response) {
        if ( !response.data.error ) { 
          console.log(response.data);
          $scope.current_ot = response.data.operation_type;
          $scope.operation_types.push($scope.current_ot);
          make_categories();
        } else {
          alert ( response.data.error );
        }
      });

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
