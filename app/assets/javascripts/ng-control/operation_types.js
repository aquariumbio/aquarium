(function() {

  let w = angular.module('aquarium');

  w.controller('operationTypesCtrl', [ '$scope', '$http', '$attrs', 'aqCookieManager', '$sce', '$mdDialog',
                            function (  $scope,   $http,   $attrs,   aqCookieManager,   $sce, $mdDialog ) {
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
     * Listener for `onBeforeUnload` event broadcast by the handler for browser `onbeforeunload`.
     * Sets the event defaultPrevented flag if any changes have been made to the operation type definition.
     *
     * See factory definition in ng-helper/beforeunload_factory.js.
     */
    $scope.$on('onBeforeUnload', function (e) {
      if ($scope.operation_type_changed()) {
          e.preventDefault();
      }
    });

    function isType(operation_type, type) {
      "use strict";
      return operation_type && operation_type.model && operation_type.model.model === type;
    }

    $scope.operation_type_changed = function() {
      "use strict";
      return $scope.current_operation_type
        && ($scope.current_operation_type.changed
          || (isType($scope.current_operation_type, 'OperationType')
            && ($scope.current_operation_type.protocol.changed
              || $scope.current_operation_type.precondition.changed
              || $scope.current_operation_type.documentation.changed))
          || (isType($scope.current_operation_type.model.model, 'Library')
            && $scope.current_operation_type.source.changed)
        );
    };

    function make_categories() {

      $scope.categories = aq.uniq(aq.collect($scope.operation_types.concat($scope.libraries),function(ot) {
        return ot.category;
      })).sort();

      let category = aqCookieManager.get_object("DeveloperCurrentCategory");
      if ( category ) {
        $scope.choose_category(category);
      } else if ( $scope.categories.length > 0 && !$scope.current_category ) {
        $scope.choose_category($scope.categories[0]);
      }

    }

    function getCurrentOperationType(aqCookieManager, $scope) {
      let current_operation_type_id = aqCookieManager.get_object("DeveloperCurrentOperationTypeId");
      if (current_operation_type_id) {
          let operation_types = aq.where($scope.operation_types, operation_type => operation_type.id === current_operation_type_id);
          if (operation_types.length === 1) {
              return operation_types[0];
          }
          else {
              return $scope.operation_types[0];
          }
      }
      else {
          return $scope.operation_types[0];
      }
  }


    AQ.OperationType.all({methods: ["field_types", "timing"]}).then(operation_types => {

      $scope.operation_types = operation_types;
      AQ.operation_types = $scope.operation_types;

      aq.each($scope.operation_types, operation_type => {
          operation_type.upgrade_field_types();
          if ( operation_type.timing ) {
              operation_type.timing = AQ.Timing.record(operation_type.timing);
          } else {
              operation_type.set_default_timing();
          }
          operation_type.timing.make_form();
      });

      $scope.current_operation_type = getCurrentOperationType(aqCookieManager, $scope);

      AQ.Library.all().then(libraries => {
        $scope.libraries = libraries;
        make_categories();
      });


      let mode = aqCookieManager.get_object("DeveloperMode");
      if ( mode ) {
        $scope.set_mode(mode);
      } else {
        $scope.set_mode('definition');
      }

      $scope.initialized = true;
      $scope.$apply();
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

    //TODO need to manage tabs separately from library/operation-type, currently mode means tab (mostly)
    $scope.set_mode = function(mode) {
      aqCookieManager.put_object("DeveloperMode",mode);
      $scope.mode = mode;
    };

    $scope.choose = function(operation_type) {
      $scope.current_operation_type = operation_type;
      $scope.set_mode('definition');
      aqCookieManager.put_object("DeveloperCurrentOperationTypeId", operation_type.id);
      aqCookieManager.put_object("DeveloperSelectionType", "OperationType");
    };

    $scope.choose_lib = function(library) {
      $scope.current_operation_type = library;
      $scope.set_mode('source');
      aqCookieManager.put_object("DeveloperCurrentOperationTypeId", library.id);
      aqCookieManager.put_object("DeveloperSelectionType", "Library");
    };

    $scope.choose_category = function(category) {
      if ( $scope.current_category === category ) {
        delete $scope.current_category;
      } else {
        $scope.current_category = category;
        aqCookieManager.put_object("DeveloperCurrentCategory", category);
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
              aqCookieManager.put_object("DeveloperCurrentCategory", $scope.current_operation_type.category);
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
              aqCookieManager.put_object("DeveloperCurrentOperationTypeId", $scope.current_operation_type.id);
              aqCookieManager.put_object("DeveloperCurrentCategory", $scope.current_operation_type.category);
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
        aqCookieManager.put_object("DeveloperCurrentOperationTypeId", $scope.current_operation_type.id);
        $scope.current_category = c;
        aqCookieManager.put_object("DeveloperCurrentCategory", c);
      } else if ( $scope.operation_types.length > 0 ) {
        $scope.current_operation_type = $scope.operation_types[0];
        aqCookieManager.put_object("DeveloperCurrentOperationTypeId", $scope.current_operation_type.id);
        $scope.current_category = $scope.current_operation_type.category;
        aqCookieManager.put_object("DeveloperCurrentCategory", $scope.current_operation_type.category);
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

          } else  if ( response.data.inconsistencies.length === 0 ) {

            if ( response.data.operation_types.length > 0 ) {

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
      let new_operation_type = AQ.OperationType.record({
        name: "New Operation Type",
        category: $scope.current_category ? $scope.current_category : "Unsorted",
        deployed: false,
        changed: true,
        field_types:[],
        protocol: AQ.Code.record({ name: 'protocol', content: $scope.default_protocol }),
        cost_model: AQ.Code.record({ name: 'cost_model', content: 'def cost(_op)\n  { labor: 0, materials: 0 }\nend' }),
        precondition: AQ.Code.record({ name: 'precondition', content: 'def precondition(_op)\n  true\nend'}),
        documentation: AQ.Code.record({ name: 'documentation', content: "Documentation here. Start with a paragraph, not a heading or title, as in most views, the title will be supplied by the view."})
      });
      $scope.operation_types.push(new_operation_type);
      $scope.current_operation_type = new_operation_type;
      make_categories();
      $scope.current_category = new_operation_type.category;
      $scope.set_mode("definition");
    };

    $scope.new_library = function() {

      let lib = AQ.Library.record({
        name: "New Library Code",
        category: $scope.current_category && $scope.current_category !== "" ? $scope.current_category : "Unsorted",
        source: AQ.Code.record({ name: 'protocol', content: "# Library code here" })
      });

      $http.post("/libraries", lib).then( response => {

        let newlib = AQ.Library.record(response.data);
        $scope.change(newlib);
        $scope.libraries.push(newlib);
        $scope.current_operation_type = newlib;
        make_categories();
        $scope.current_category = newlib.category;
        $scope.set_mode('source');
      });

    };

    $scope.update_library = function(library) {

      if ( confirm("Are you sure you want to change the name and/or category of this library?") ) {

        $http.put("/libraries/" + library.id,library).then(function(response) {
          $scope.unchange(library);
        });

      }

    };

    $scope.delete_library = function(library) {

      if ( confirm("Are you sure you want to delete this library?") ) {
        let category = library.category;

        $http.delete("/libraries/" + library.id,library).then(function(response) {
          if ( response.data.error ) {
            alert ( "Could not delete library: " + response.data.error );
          } else {
            $scope.libraries = aq.remove($scope.libraries,library);
            after_delete(category);
            $scope.set_mode('definition');
          }
        });             
      }
    };

    $scope.copy = function(operation_type) {

      $http.get("/operation_types/" + operation_type.id + "/copy/").then(function(response) {
        if ( !response.data.error ) { 
          alert("Copy successful. Developer page will reload.")
          $scope.reload();
        } else {
          alert ( response.data.error );
        }
      });

    };

    $scope.render_docs = function(operation_type) {
      var md = window.markdownit();
      operation_type.rendered_docs = $sce.trustAsHtml(md.render(operation_type.documentation.content));
      $scope.set_mode('documentation_view');
    };

    $scope.edit_docs = function(operation_type) {
      $scope.set_mode('documentation');
    };

    $scope.containers_for = function(sample_name)  {
      return [ sample_name, "Whatever", "Works" ]
    };

    $scope.change = function(thing) {
      thing['changed'] = true;
    };

    $scope.unchange = function(thing) {
      thing['changed'] = false;
    }

    $scope.reload = function() {
      window.location = "/operation_types"
    }

  }]);

})();
