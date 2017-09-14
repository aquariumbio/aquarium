(function() {

  let w = angular.module('aquarium');

  // Broadcast event to angular
  // see https://gist.github.com/981746/3b6050052ffafef0b4df
  //
  w.factory('beforeUnload', function ($rootScope, $window) {
      // Events are broadcast outside the Scope Lifecycle

      $window.onbeforeunload = function (e) {
          var confirmation = {};
          var event = $rootScope.$broadcast('onBeforeUnload', confirmation);
          if (event.defaultPrevented) {
              console.log("default was prevented?");
          } else {
              return true;
          }
      };

      $window.onunload = function () {
          $rootScope.$broadcast('onUnload');
      };
      return {};
  })
  .run(function (beforeUnload) {
       // Must invoke the service at least once
   });

  w.controller('operationTypesCtrl', [ '$scope', '$http', '$attrs', '$cookies', '$sce', '$mdDialog',
                            function (  $scope,   $http,   $attrs,   $cookies,   $sce, $mdDialog ) {

    AQ.init($http);
    AQ.update = () => { $scope.$apply(); };
    AQ.confirm = (msg) => { return confirm(msg); };
    AQ.sce = $sce;

    $scope.operation_types = [];
    $scope.current_operation_type = null;
    $scope.user = new User($http);  
    $scope.default_protocol = "";
    $scope.categories = [];
    $scope.initialized = false;

    $scope.import_popup = {};

    /*
     * Set handler for onbeforeunload.
     * See factory definition above.
     */
    $scope.$on('onBeforeUnload', function (e, confirmation) {
        console.log("handling onbeforeunload");
        if ($scope.current_operation_type.changed
            || $scope.current_operation_type.protocol.changed
            || $scope.current_operation_type.precondition.changed) {
            console.log("changed operation type");
        } else {
            console.log("unchanged operation type");
            e.preventDefault();
        }
    });

    function make_categories() {

      $scope.categories = aq.uniq(aq.collect($scope.operation_types.concat($scope.libraries),function(ot) {
        return ot.category;
      })).sort();

      if ( get_object("DeveloperCurrentCategory") ) {
        $scope.choose_category(get_object("DeveloperCurrentCategory"));
      } else if ( $scope.categories.length > 0 && !$scope.current_category ) {
        $scope.choose_category($scope.categories[0]);
      }

    }

    /*
     * Cookie management -- common to operation.js, developer.js and browser.js --- should be factored out
     */
     function cookie_name(name) {
       return aquarium_environment_name + "_" + name;
     }

     function put_object(name, object) {
       $cookies.putObject(cookie_name(name), object);
     }

     function get_object(name) {
        return $cookies.getObject(cookie_name(name))
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

        if ( get_object("DeveloperCurrentOperationTypeId") ) {
          let ots = aq.where($scope.operation_types,ot => ot.id === get_object("DeveloperCurrentOperationTypeId") );
          if  ( ots.length === 1 ) {
            $scope.current_operation_type = ots[0];
          } else {
            $scope.current_operation_type = $scope.operation_types[0];
          }
        } else {
          $scope.current_operation_type = $scope.operation_types[0];
        }

        make_categories();

        if ( get_object("DeveloperMode") ) {
          $scope.mode = get_object("DeveloperMode");
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
      return mode === $scope.mode ? "active" : "";
    };

    $scope.set_mode = function(mode) {
      put_object("DeveloperMode",mode);
      $scope.mode = mode;
    };

    $scope.choose = function(operation_type) {
      $scope.current_operation_type = operation_type;
      $scope.mode = 'definition';
      put_object("DeveloperCurrentOperationTypeId", operation_type.id);
      put_object("DeveloperSelectionType", "OperationType");
    };

    $scope.choose_lib = function(library) {
      $scope.current_operation_type = library;
      $scope.mode = 'source';
      put_object("DeveloperCurrentOperationTypeId", library.id);
      put_object("DeveloperSelectionType", "Library");
    };

    $scope.choose_category = function(category) {
      if ( $scope.current_category === category ) {
        delete $scope.current_category;
      } else {
        $scope.current_category = category;
        put_object("DeveloperCurrentCategory", category);
      }
    };

    $scope.category_size = function(category) {
      return aq.where($scope.operation_types,function(ot) { return ot.category === category; }).length;
    };

    $scope.operation_type_class = function(operation_type) {
      let c = "clickable op-type";
      if ( $scope.current_operation_type === operation_type ) {
        c += " op-type-current";
      } 
      if ( operation_type.deployed ) {
        c += " op-type-deployed"
      }
      return c;
    };

    $scope.lib_class = function(library) {
      let c = "clickable library";
      if ( $scope.current_operation_type === library ) {
        c += " library-current";
      } 
      return c;
    };

    $scope.capitalize = function(string) {
      return string.charAt(0).toUpperCase() + string.slice(1);
    };

    $scope.save_operation_type = function(operation_type) {
      if ( confirm ( "Are you sure you want to save this operation type definition?" ) ) {
        if ( operation_type.id ) {
          $http.put("/operation_types/" + operation_type.id,operation_type.remove_predecessors()).then(function(response) {
            if ( response.data.errors ) {
              alert ( "Could not update operation type definition: " + response.data.errors[0] );
              console.log(response.data.errors);
            } else {
              let i = $scope.operation_types.indexOf(operation_type);
              $scope.operation_types[i] = AQ.OperationType.record(response.data);
              $scope.current_operation_type = $scope.operation_types[i];
              $scope.current_operation_type.upgrade_field_types();
              make_categories();
              $scope.current_category = $scope.current_operation_type.category;
              put_object("DeveloperCurrentCategory", $scope.current_operation_type.category);
            }
          });          
        } else {
          $http.post("/operation_types",operation_type).then(function(response) {
            let i = $scope.operation_types.indexOf(operation_type);
            if ( response.data.errors ) {
              alert ( "Could not update operation type definition: " + response.data.errors[0] );
            } else {            
              $scope.operation_types[i] = AQ.OperationType.record(response.data);          
              $scope.current_operation_type = $scope.operation_types[i];
              $scope.current_operation_type.upgrade_field_types();
              make_categories();
              $scope.current_category = $scope.current_operation_type.category;
              put_object("DeveloperCurrentOperationTypeId", $scope.current_operation_type.id);
              put_object("DeveloperCurrentCategory", $scope.current_operation_type.category);
            }
          });
        }
      }
    };

    function after_delete(c) {
      make_categories();
      if ( $scope.category_size(c) > 0 ) {
        let ots = aq.where($scope.operation_types, ot => ot.category === c );
        $scope.current_operation_type = ots[0];
        put_object("DeveloperCurrentOperationTypeId", $scope.current_operation_type.id);
        $scope.current_category = c;
        put_object("DeveloperCurrentCategory", c);
      } else if ( $scope.operation_types.length > 0 ) {
        $scope.current_operation_type = $scope.operation_types[0];
        put_object("DeveloperCurrentOperationTypeId", $scope.current_operation_type.id);
        $scope.current_category = $scope.current_operation_type.category;
        put_object("DeveloperCurrentCategory", $scope.current_operation_type.category);
      }      
    }

    $scope.delete_operation_type = function(operation_type) {
      if ( confirm ( "Are you sure you want delete this operation type definition?" ) ) {

        if ( operation_type.id ) {

          $http.delete("/operation_types/" + operation_type.id,operation_type).then(function(response) {
            if ( response.data.error ) {
              alert ( "Could not delete operation type: " + response.data.error );
            } else {
              let i = $scope.operation_types.indexOf(operation_type),
                  c = operation_type.category;
              $scope.operation_types.splice(i,1);
              after_delete(c);
            }
          });             

        } else { // operation type hasn't been saved yet

          let i = $scope.operation_types.indexOf(operation_type),
              c = operation_type.category;
          $scope.operation_types.splice(i,1);
          after_delete(c);          
        }

      }
    };

    $scope.export_operation_type = function(operation_type) {
      $http.get("/operation_types/" + operation_type.id + "/export").then(function(response) {

        if ( response.data.error ) {

          alert(response.data.error);

        } else {

          let blob = new Blob([JSON.stringify(response.data)], { type:"application/json;charset=utf-8;" });
          let downloadLink = angular.element('<a></a>');
                            downloadLink.attr('href',window.URL.createObjectURL(blob));
                            downloadLink.attr('download', operation_type.name + '.json');
          downloadLink[0].click();

        }

      });
    };

    $scope.export_category = function(category) {
      $http.get("/operation_types/export_category/" + category).then(function(response) {

        if ( response.data.error ) {

          alert(response.data.error);

        } else {        

          let blob = new Blob([JSON.stringify(response.data)], { type:"application/json;charset=utf-8;" });
          let downloadLink = angular.element('<a></a>');
                            downloadLink.attr('href',window.URL.createObjectURL(blob));
                            downloadLink.attr('download', category + '.json');
          downloadLink[0].click();

        }

      });
    };

    $scope.import = function() {

      let file = document.getElementById('import').files[0],
          reader = new FileReader();

      reader.onloadend = function(e) {

        try {
          let json = JSON.parse(e.target.result);
        } catch(e) {
          alert("Could not parse file: " + e);
          return;
        }

        $scope.import_popup.loading = true;

        $http.post("/operation_types/import", { operation_types: json }).then(function(response) {

          $scope.import_popup.loading = false;

          if ( response.data.error ) {

            alert (response.data.error)

          } else  if ( response.data.inconsistencies.length === 0 ) {

            if ( response.data.operation_types.length > 0 ) {

              let operation_types = aq.collect(response.data.operation_types, raw_operation_type => {
                let operation_type = AQ.OperationType.record(raw_operation_type);
                operation_type.upgrade_field_types();
                if ( raw_operation_type.timing ) {
                  operation_type.timing = AQ.Timing.record(raw_operation_type.timing);
                } else { 
                  operation_type.set_default_timing();
                }
                operation_type.timing.make_form();
                return operation_type;
              });

              $scope.operation_types = $scope.operation_types.concat(operation_types);
              make_categories();
              $scope.current_operation_type = response.data.operation_types[0];
              $scope.current_category = $scope.current_operation_type.category;
              $scope.import_notification(response.data);

            } else {

              alert ( "No operation types found in file." );

            }

          } else {

            $scope.import_notification(response.data);

          }

        });

      };

      reader.readAsBinaryString(file);

    };

    $scope.import_notification = function(data) {
      console.log('import notification');
      $scope.import_popup = data;
      $scope.import_popup.show = true;
    };

    $scope.new_operation_type = function() {
      var new_operation_type = AQ.OperationType.record({
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
      $scope.operation_types.push(new_operation_type);
      $scope.current_operation_type = new_operation_type;
      make_categories();
      $scope.current_category = new_operation_type.category;
      $scope.mode = "definition";
    };

    $scope.new_library = function() {

      var lib = AQ.Library.record({
        name: "Library Code",
        category: $scope.current_category && $scope.current_category !== "" ? $scope.current_category : "Unsorted",
        source: AQ.Code.record({ name: 'protocol', content: "# Library code here" })
      });

      $http.post("/libraries", lib).then( response => {

        var newlib = AQ.Library.record(response.data);
        $scope.libraries.push(newlib);
        $scope.current_operation_type = newlib;
        make_categories();
        $scope.current_category = newlib.category;
        $scope.mode = 'source';

      });

    };

    $scope.update_library = function(library) {

      if ( confirm("Are you sure you want to change the name and/or category of this library?") ) {

        $http.put("/libraries/" + library.id,library).then(function(response) {
          library.changed = false;
        });

      }

    };

    $scope.delete_library = function(library) {

      if ( confirm("Are you sure you want to delete this library?") ) {

        $http.delete("/libraries/" + library.id,library).then(function(response) {
          if ( response.data.error ) {
            alert ( "Could not delete library: " + response.data.error );
          } else {
            $scope.libraries = aq.remove($scope.libraries,library);
          }
        });             

      }

    };

    $scope.copy = function(operation_type) {

      $http.get("/operation_types/" + operation_type.id + "/copy/").then(function(response) {
        if ( !response.data.error ) { 
          $scope.current_operation_type = response.data.operation_type;
          $scope.operation_types.push($scope.current_operation_type);
          make_categories();
          $scope.current_category = $scope.current_operation_type.category;
        } else {
          alert ( response.data.error );
        }
      });

    };

    $scope.render_docs = function(operation_type) {
      var md = window.markdownit();
      operation_type.rendered_docs = $sce.trustAsHtml(md.render(operation_type.documentation.content));
      $scope.mode = 'documentation_view'; 
    };

    $scope.edit_docs = function(operation_type) {
      $scope.mode = 'documentation';
    };

    $scope.containers_for = function(sample_name)  {
      return [ sample_name, "Whatever", "Works" ]
    };

    $scope.change = function(thing) {
      thing.changed = true;
    };

    $scope.unchange = function(thing) {
      thing.changed = false;
    }

  }]);

})();
