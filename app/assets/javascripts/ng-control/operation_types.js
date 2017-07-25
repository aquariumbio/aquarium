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
    AQ.sce = $sce;

    $scope.operation_types = [];
    $scope.current_ot = null;
    $scope.user = new User($http);  
    $scope.default_protocol = "";
    $scope.categories = [];
    $scope.initialized = false;

    $scope.import_popup = {};

    function make_categories() {

      $scope.categories = aq.uniq(aq.collect($scope.operation_types.concat($scope.libraries),function(ot) {
        return ot.category;
      })).sort();

      if ( $cookies.getObject("DeveloperCurrentCategory") ) {
        $scope.choose_category($cookies.getObject("DeveloperCurrentCategory"));
      } else if ( $scope.categories.length > 0 && !$scope.current_category ) {
        $scope.choose_category($scope.categories[0]);
      }

    }

    AQ.OperationType.all({methods: ["field_types", "timing"]}).then(operation_types => {

      AQ.Library.all().then(libraries => {

        $scope.operation_types = operation_types;
        AQ.operation_types = $scope.operation_types;

        $scope.libraries = libraries;

        aq.each($scope.operation_types, ot => {
          ot.upgrade_field_types();
          if ( ot.timing ) {
            ot.timing = AQ.Timing.record(ot.timing);
          } else { 
            ot.set_default_timing();
          }
          ot.timing.make_form();
        });       

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

        if ( $cookies.getObject("DeveloperMode") ) {
          $scope.mode = $cookies.getObject("DeveloperMode");
        } else {
          $scope.mode = 'definition';
        }      

        $scope.initialized = true;            
        $scope.$apply();

      });

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
      $cookies.putObject("DeveloperMode",mode) 
      $scope.mode = mode;
    }

    $scope.choose = function(ot) {
      $scope.current_ot = ot;
      $scope.mode = 'definition';
      $cookies.putObject("DeveloperCurrentOperationTypeId", ot.id); 
      $cookies.putObject("DeveloperSelectionType", "OperationType");             
    }

    $scope.choose_lib = function(lib) {
      $scope.current_ot = lib;
      $scope.mode = 'source';
      $cookies.putObject("DeveloperCurrentOperationTypeId", lib.id); 
      $cookies.putObject("DeveloperSelectionType", "Library");       
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
      var c = "clickable op-type";
      if ( $scope.current_ot == ot ) {
        c += " op-type-current";
      } 
      if ( ot.deployed ) {
        c += " op-type-deployed"
      }
      return c;
    }

    $scope.lib_class = function(lib) {
      var c = "clickable library";
      if ( $scope.current_ot == lib ) {
        c += " library-current";
      } 
      return c;
    }    

    $scope.capitalize = function(string) {
      return string.charAt(0).toUpperCase() + string.slice(1);
    }

    $scope.save_ot = function(ot) {
      if ( confirm ( "Are you sure you want to save this operation type definition?" ) ) {
        if ( ot.id ) {
          $http.put("/operation_types/" + ot.id,ot.remove_predecessors()).then(function(response) {
            if ( response.data.errors ) {
              alert ( "Could not update operation type definition: " + response.data.errors[0] )
              console.log(response.data.errors);
            } else {
              var i = $scope.operation_types.indexOf(ot);
              $scope.operation_types[i] = AQ.OperationType.record(response.data);
              $scope.current_ot = $scope.operation_types[i];
              $scope.current_ot.upgrade_field_types()
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
            } else {            
              $scope.operation_types[i] = AQ.OperationType.record(response.data);          
              $scope.current_ot = $scope.operation_types[i]
              $scope.current_ot.upgrade_field_types() 
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

        if ( response.data.error ) {

          alert(response.data.error);

        } else {

          var blob = new Blob([JSON.stringify(response.data)], { type:"application/json;charset=utf-8;" });     
          var downloadLink = angular.element('<a></a>');
                            downloadLink.attr('href',window.URL.createObjectURL(blob));
                            downloadLink.attr('download', ot.name + '.json');
          downloadLink[0].click();

        }

      });
    }

    $scope.export_category = function(category) {
      $http.get("/operation_types/export_category/" + category).then(function(response) {

        if ( response.data.error ) {

          alert(response.data.error);

        } else {        

          var blob = new Blob([JSON.stringify(response.data)], { type:"application/json;charset=utf-8;" });     
          var downloadLink = angular.element('<a></a>');
                            downloadLink.attr('href',window.URL.createObjectURL(blob));
                            downloadLink.attr('download', category + '.json');
          downloadLink[0].click();

        }

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

        $scope.import_popup.loading = true;

        $http.post("/operation_types/import", { operation_types: json }).then(function(response) {

          $scope.import_popup.loading = false;

          if ( response.data.error ) {

            alert (response.data.error)

          } else  if ( response.data.inconsistencies.length == 0 ) {

            if ( response.data.operation_types.length > 0 ) {

              var operation_types = aq.collect(response.data.operation_types, rawot => {
                var ot = AQ.OperationType.record(rawot);
                ot.upgrade_field_types();
                if ( rawot.timing ) {
                  ot.timing = AQ.Timing.record(rawot.timing);
                } else { 
                  ot.set_default_timing();
                }
                ot.timing.make_form();
                return ot;
              });

              $scope.operation_types = $scope.operation_types.concat(operation_types);
              make_categories();
              $scope.current_ot = response.data.operation_types[0];     
              $scope.current_category = $scope.current_ot.category;         
              $scope.import_notification(response.data);

            } else {

              alert ( "No operation types found in file." );

            }

          } else {

            $scope.import_notification(response.data);

          }

        });

      }

      r.readAsBinaryString(f);

    }

    $scope.import_notification = function(data) {
      console.log('import notification')
      $scope.import_popup = data;
      $scope.import_popup.show = true;
    }

    $scope.new_operation_type = function() {
      var new_ot = AQ.OperationType.record({
        name: "New Operation Type",
        category: $scope.current_category ? $scope.current_category : "Unsorted",
        deployed: false,
        changed: true,
        field_types:[],
        protocol: AQ.Code.record({ name: 'protocol', content: $scope.default_protocol }),
        cost_model: AQ.Code.record({ name: 'cost_model', content: 'def cost(op)\n  { labor: 0, materials: 0 }\nend' }),
        precondition: AQ.Code.record({ name: 'precondition', content: 'def precondition(op)\n  true\nend'}),
        documentation: AQ.Code.record({ name: 'documentation', content: "Documentation here. Start with a paragraph, not a heading or title, as in most views, the title will be supplied by the view."})
      });
      $scope.operation_types.push(new_ot);
      $scope.current_ot = new_ot;
      make_categories();
      $scope.current_category = new_ot.category;
      $scope.mode = "definition";
    }

    $scope.new_library = function() {

      var lib = AQ.Library.record({
        name: "Library Code",
        category: $scope.current_category && $scope.current_category != "" ? $scope.current_category : "Unsorted",
        source: AQ.Code.record({ name: 'protocol', content: "# Library code here" }),
      });

      $http.post("/libraries", lib).then( response => {

        var newlib = AQ.Library.record(response.data);
        $scope.libraries.push(newlib);
        $scope.current_ot = newlib;
        make_categories();
        $scope.current_category = newlib.category;
        $scope.mode = 'source';

      });

    }

    $scope.update_library = function(lib) {

      if ( confirm("Are you sure you want to change the name and/or category of this library?") ) {

        $http.put("/libraries/" + lib.id,lib).then(function(response) {
          lib.changed = false;
        });

      }

    }

    $scope.delete_library = function(lib) {

      if ( confirm("Are you sure you want to delete this library?") ) {

        $http.delete("/libraries/" + lib.id,lib).then(function(response) {
          if ( response.data.error ) {
            alert ( "Could not delete library: " + response.data.error );
          } else {
            $scope.libraries = aq.remove($scope.libraries,lib);
          }
        });             

      }

    }

    $scope.copy = function(ot) {

      $http.get("/operation_types/" + ot.id + "/copy/").then(function(response) {
        if ( !response.data.error ) { 
          $scope.current_ot = response.data.operation_type;
          $scope.operation_types.push($scope.current_ot);
          make_categories();
          $scope.current_category = $scope.current_ot.category;
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
