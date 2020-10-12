(function() {

  var w = angular.module('aquarium'); 

  w.controller('itemCtrl', [ '$scope', '$http', '$mdDialog', '$window', 
                  function (  $scope,   $http,   $mdDialog,   $window ) {

    AQ.init($http);
    AQ.update = () => { $scope.$apply(); }
    AQ.confirm = (msg) => { return confirm(msg); }

    $scope.status = {};
    $scope.item_id = aq.url_path()[2];
    $scope.last_click = [0,0];
    $scope.selection = [];
    $scope.samples_loaded = false;
    $scope.mode = 'samples';
    $scope.info = { sample_identifier: null }; // Autocomlete needs a field of an object

    AQ.Item.where({id: $scope.item_id}, {include: "object_type"}).then(items => {
      if ( items.length != 1 ) {
        alert("Could not find item " + $scope.item_id)
      } else if ( items[0].is_collection ) {
        AQ.Collection
          .find_fast($scope.item_id)
          .then(collection => {
            $scope.collection = collection;
            AQ.get_sample_names().then(() => $scope.samples_loaded = true);
          })
      } else {
        $scope.item = items[0];
      }
    }); 

    $scope.openMenu = function($mdMenu, ev) {
      originatorEv = ev;
      $mdMenu.open(ev);
    };

    $scope.new_data_key = function() {
      let dialog = $mdDialog.prompt()
          .title('New data key name?')
          .textContent("What should the new data field be named?")
          .ariaLabel('Key name')
          .placeholder('key')
          .initialValue('key')
          .required(true)
          .ok('OK')
          .cancel('Cancel');

      let old_collection = $scope.collection;

      $mdDialog
        .show(dialog)
        .then(result => {
          $scope.key = result;
          $scope.collection.extend_data_association(result);
          $scope.collection.recompute_getter('data_keys')
          $scope.set_mode('data');
        })
        .catch(e => console.log("New data key not created",e));
      
    }

    $scope.data_changed = function() {
      let rval = false;
      aq.each($scope.collection.parts, part => {
        aq.each(part.data_associations, da => {
          if ( da.value != da.new_value ) {
            rval = true;
          }
        })
      });
      return rval;
    }

    $scope.undo_data_changes = function() {
      aq.each($scope.collection.parts, part => {
        aq.each(part.data_associations, da => {
          if ( da.value != da.new_value ) {
            da.set(da.value);
          }
        })
      });
    }

    $scope.save_data = function() {
      $scope.saving = true
      $scope.collection.save_data_associations()
            .then(() => $scope.saving = false)
    }

    $scope.choose_data_key = function(key) {
      $scope.key = key;
      $scope.collection.extend_data_association(key)
      $scope.set_mode('data');
    }

    $scope.set_mode = function(mode) {
      $scope.mode = mode;
      $scope.clear_selection();
    }

    $scope.mode_class = function(mode) {
      let c = "md-raised ";
      if ( mode == $scope.mode ) {
        c += "md-primary";
      }
      return c;
    }

    $scope.gang_data_associations = function(value) {
      for ( var r=0; r<$scope.collection.part_matrix.length; r++ ) {
        for ( var c = 0; c < $scope.collection.part_matrix[r].length; c++ ) {
          if ( $scope.collection.part_matrix[r][c].record_type == "Item" && 
               $scope.collection.part_matrix[r][c].selected ) {
            $scope.collection.part_matrix[r][c].data_association($scope.key).new_value = value;
          }
        }
      }
    }

    $scope.clear_selection = function() {
      for ( var r=0; r<$scope.collection.part_matrix.length; r++ ) {
        for ( var c = 0; c < $scope.collection.part_matrix[r].length; c++ ) {
          $scope.collection.part_matrix[r][c].selected = false;
        }
      }
      $scope.selection = [];
      $scope.part = null;
      $scope.row = null;
      $scope.column = null;     
      $scope.selection_box = {}; 
    }

    $scope.select = function(part,r,c,event) {

      $scope.clear_selection();
      
      if ( event.shiftKey ) {

        let r1 = Math.min(r,$scope.last_click[0]),
            r2 = Math.max(r,$scope.last_click[0]),
            c1 = Math.min(c,$scope.last_click[1]),
            c2 = Math.max(c,$scope.last_click[1]);           

        for ( var i=r1; i<=r2; i++ ) {
          for ( var j=c1; j<=c2; j++ ) {
            $scope.collection.part_matrix[i][j].selected = true;
          }
        }

      } else {
        
        part.selected = true;
        $scope.last_click = [r,c];

      }

      store_selection();
      update_selection_box();

    }

    $scope.select_all = function() {
      for ( var i=0; i<$scope.collection.object_type.rows; i++ ) {
        for ( var j=0; j<$scope.collection.object_type.columns; j++ ) {
          $scope.collection.part_matrix[i][j].selected = true;
        }
      }  
      store_selection();
      update_selection_box();      
    }

    $scope.select_row = function(r) {
      $scope.clear_selection();
      for ( var j=0; j<$scope.collection.object_type.columns; j++ ) {
        $scope.collection.part_matrix[r][j].selected = true;
      }
      store_selection();
      update_selection_box();        
    }

    $scope.select_column = function(c) {
      $scope.clear_selection();
      for ( var i=0; i<$scope.collection.object_type.rows; i++ ) {
        $scope.collection.part_matrix[i][c].selected = true;
      }
      store_selection();
      update_selection_box();     
    }

    $scope.cell_class = function(part,r,c) {
      let klass = "no-highlight";
      if ( !part.rid ) {
        klass += " no-part";
      }
      if ( $scope.mode == 'data' ) {
        klass += " no-padding"
      }
      return klass;
    }

    $scope.keydown = function(evt) {

      switch(evt.key) {
        case "Escape":
          $scope.clear_selection();
          break;
      }

    }

    $scope.assign_sample = function() {

      let confirm = $mdDialog.confirm()
          .title('Associate Sample?')
          .textContent("Associating sample with the selected parts will discard any existing associations.")
          .ariaLabel('Revert')
          .ok('Yes')
          .cancel('No');

      let old_collection = $scope.collection;

      $mdDialog
        .show(confirm)
        .then(() =>  $scope.collection.assign_sample_to_selection($scope.info.sample_identifier))
        .then(collection => $scope.collection = collection)
        .then(collection => $scope.collection.recompute_getter('data_associations'))
        .then(collection => copy_selection(old_collection, $scope.collection))
        .catch(e => console.log("Sample not assigned",e))

    }

    $scope.delete_parts = function() {

      let confirm = $mdDialog.confirm()
          .title('Delete Sample from Collection?')
          .textContent("Deleting samples from the selected parts will discard any existing associations.")
          .ariaLabel('Revert')
          .ok('Yes')
          .cancel('No');

      let old_collection = $scope.collection;

      $mdDialog
        .show(confirm)
        .then(() =>  $scope.collection.delete_selection())
        .then(collection => $scope.collection = collection)
        .then(collection => $scope.collection.recompute_getter('data_associations'))
        .then(collection => copy_selection(old_collection, $scope.collection))
        .catch(e => console.log("Parts not deleted",e))  

    }

    function copy_selection(from,to) {
      for ( var r=0; r<from.part_matrix.length; r++ ) {
        for ( var c=0; c<from.part_matrix[r].length; c++ ) {
          to.part_matrix[r][c].selected = from.part_matrix[r][c].selected;
        }
      }
      store_selection();
      update_selection_box();
    }

    function store_selection() {

      let parts = [], row, column;

      for ( var r=0; r<$scope.collection.part_matrix.length; r++ ) {
        for ( var c = 0; c < $scope.collection.part_matrix[r].length; c++ ) {
          if ( $scope.collection.part_matrix[r][c].selected ) {
            parts.push($scope.collection.part_matrix[r][c]);
            row = r;
            column = c;
          }
        }
      }

      $scope.selection = parts;

      if ( $scope.selection.length == 1 ) {
        $scope.part = $scope.selection[0];
        $scope.row = row;
        $scope.column = column;
      } else {
        $scope.part = null;
        $scope.row = null;
        $scope.column = null;
      }

    }

    angular.element($window).bind('resize', function(){
      update_selection_box();  
      $scope.$apply();
    });

    function update_selection_box() {

      setTimeout(function(){

        let x1 = 100000,
            y1 = 100000,
            x2 = 0, 
            y2 = 0;

        $('*[data-selected=true]').each(function() {
          if ( $(this).position().left < x1 ) {
            x1 = $(this).position().left;
          }
          if ( $(this).position().top < y1 ) {
            y1 = $(this).position().top;
          }   
          if ( $(this).position().left + $(this).outerWidth() > x2 ) {
            x2 = $(this).position().left + $(this).outerWidth()
          }
          if ( $(this).position().top + $(this).outerHeight() > y2 ) {
            y2 = $(this).position().top + $(this).outerHeight()
          }
          if ( $scope.mode == 'data' ) {
            $(this).find("input").focus();
          }
        });

        $scope.selection_box = { x: x1+1, y: y1+1, width: x2-x1-1, height: y2-y1-1 };

        $scope.$apply();

      },30);

    }

  }]);

})();                    
