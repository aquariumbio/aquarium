(function() {

  var w;

  try {
    w = angular.module('aquarium'); 
  } catch (e) {
    w = angular.module('aquarium', ['ngCookies','ui.ace']); 
  } 

  w.controller('sampleCtrl', [ '$scope', '$http', '$attrs', function ($scope,$http,$attrs) {

    $scope.user = new User($http);

    $scope.toggle = function(sample) {
      if ( !sample.edit ) {
        if ( sample.open ) {
          sample.open = false;
        } else {
          sample.find(sample.id,function(sample) {
            sample.open = true;
          });
        }
      }
    }

    $scope.toggle_show_deleted = function(sample) {
      sample.show_deleted = !sample.show_deleted;
      console.log("switched to " + sample.show_deleted)
    }

    $scope.edit = function(sample) {
      sample.edit = true;
      sample.inventory = false;
    }

    $scope.view = function(sample) {  
      sample.find(sample.id, function(sample) {
        sample.edit = false;
      });
    }    

    $scope.save = function(sample) {
      sample.update(function(response) {
        if ( response.save_error ) {
          $scope.errors = response.save_error;
        } else {
          $scope.messages = [ "Saved changes to sample " + sample.id + ": " + sample.name ]
          sample.from(response);
          sample.edit = false;
        }
      });
    }

    $scope.fv_name_filter = function(field_type_name) {
      return function(fv) {
        return fv.name == field_type_name && !fv.deleted;
      }
    }    

    $scope.remove_from_array = function(fv) {    
      fv.deleted = true;
    }    

    $scope.is_empty_array = function(sample,ft) {
      var fvs = aq.where(sample.fields(ft.name),function(fv) {
        return !fv.deleted;
      });
      return fvs.length == 0;
    }

    $scope.add_to_array = function(sample,ft) {
      var fv = sample.sample_type.default_field(ft);
      fv.allowable_child_types = sample.allowable(fv.name);
      sample.field_values.push(fv);
    }    

    $scope.toggle_new_existing = function(sample,fv) {
      fv.choice = (!fv.choice || fv.choice == 'existing') ? 'new' : 'existing';
      fv.allowable_child_types = sample.allowable(fv.name);
    }  
    
    $scope.new_sub_sample = function(sample,fv,st_name) {
      var st = $scope.sample_type_from_name(st_name);
      fv.new_child_sample = new Sample($http).new(st.id,function(child) {
        fv.new_child_sample.name = sample.name + "-" + fv.name.toLowerCase() ;
        fv.new_child_sample.description = "The " + fv.name.toLowerCase() + " for " + sample.name;
        fv.new_child_sample.project = sample.project;
      });
    }

    $scope.remove_subsample = function(fv) {
      fv.new_child_sample = null;
    }

    $scope.new_subsample_button_class = function(sample,st_name) {
      if ( sample && sample.sample_type && sample.sample_type.name == st_name ) {
        return "btn btn-primary btn-mini sample-choice";
      } else {
        return "btn btn-mini sample-choice";        
      }
    }     

    $scope.non_sample = function(ft) {
      return ft.ftype != 'sample';
    }     

    $scope.allowed = function(sample) {
      var admin = aq.where($scope.user.current.groups,function(g) {
        return g.name == 'admin';
      });
      return admin.length > 0 || $scope.user.current.id == sample.user_id;
    }    

    $scope.toggle_inventory = function(sample) {
      if ( !sample.edit && sample.inventory ) {
        sample.inventory = false;
      } else if ( !sample.edit ) {
        sample.get_inventory(function() {
          sample.inventory = true;
        });
      }
    }     

  }]);

})();
