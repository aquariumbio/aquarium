(function() {

  var w;

  try {
    w = angular.module('tree'); 
  } catch (e) {
    w = angular.module('tree', []); 
  } 

  var all_samples = {};

  w.controller('treeCtrl', [ '$scope', '$http', '$attrs', 'treeAjax', function ($scope,$http,$attrs,treeAjax) {

    // Initialization

    $scope.new_samples = [];
    $scope.sample_types = [];
    $scope.projects_info = {};
    $scope.samples = {};
    $scope.projects = {};    
    $scope.project_choice = "user";
    $scope.mode = "view";
    $scope.users = [];
    $scope.current = {};
    $scope.logins = [];

    $scope.samples_loaded = false;
    $scope.types_loaded = false;
    $scope.projects_loaded = false;

    $scope.current_selection = { project: null, sample_type: null, loaded: false };

    treeAjax.sample_types(function(data) {
      $scope.sample_types = data;
      aq.each($scope.sample_types,function(st) {
        st.fields = $scope.fields(st);
      });
      $scope.samples_loaded = true;
    });

    treeAjax.user_info(function(users,current) {
      $scope.users = users;
      $scope.current_user = current;
      aq.each($scope.users,function(user) {
        $scope.logins[user.id] = user.login;
      })
    });

    $.ajax({
      url: '/samples/all'
    }).done(function(samples) {
      all_samples = samples;
      $scope.types_loaded = true;
    });    

    $.ajax({
      url: '/samples/projects'
    }).done(function(plist) {
      $scope.project_info = plist;
      $scope.projects = $scope.project_info.user;
      $scope.projects_loaded = true;
    });        

    // Button methods

    $scope.new_sample = function() {
      var st = aq.where($scope.sample_types,function(s) { return s.id == $scope.sample_type_choice })[0];
      $scope.new_samples.push($scope.empty_sample(st));
      $scope.mode = 'new';
    }

    $scope.new_sub_sample = function(sample,field,st_name) {
      var st = aq.where($scope.sample_types,function(s) { return s.name == st_name })[0];   
      field.sample = $scope.empty_sample(st);
      field.sample.name = sample.name + "-" + field.name.toLowerCase() ;
      field.sample.description = "The " + field.name.toLowerCase() + " for " + sample.name;
    }

    $scope.toggle_new_existing = function ( field ) {
      if ( field.choice == 'existing' ) {
        field.choice = 'new';
        field.sample = null;
      } else {
        field.choice = 'existing';
        field.sample = "";
      }
    }

    $scope.remove_subsample = function(field) {
      field.sample = null;
    }

    $scope.new_subsample_button_class = function(field,st_name) {
      if ( field.sample && field.sample.sample_type.name == st_name ) {
        return "btn btn-primary btn-mini bigger";
      } else {
        return "btn btn-mini bigger";        
      }
    }

    $scope.remove_sample = function(sample) {
      var i = $scope.new_samples.indexOf(sample);
      $scope.new_samples.splice(i,1);
    }

    $scope.select_project = function(project) {
      $scope.current_selection.project = project.name;
      $scope.current_selection.sample_type = null;
    }    

    $scope.unselect_project = function(project) {
      if ( $scope.current_selection.project == project.name  ) {
        $scope.current_selection.project = null;
      }
    }    

    $scope.project_toggle = function() {
      $scope.project_choice = $scope.project_choice == "user" ? "all" : "user";
    }

    $scope.select_st = function(st) { 
      $scope.mode = 'view';
      $scope.current_selection.loaded = false;
      $scope.current_selection.sample_type = st.id;
      treeAjax.samples($scope.current_selection.project,$scope.current_selection.sample_type,function(samples) {
        $scope.samples[$scope.current_selection.project] = {};
        $scope.samples[$scope.current_selection.project][$scope.current_selection.sample_type] = samples;
        $scope.current_selection.loaded = true;
      });
    }

    $scope.unselect_st = function(st) {
      if ( $scope.current_selection.sample_type == st.id && $scope.mode == 'view' ) {
        $scope.current_selection.sample_type = null;
      } else {
        $scope.mode = 'view';
      }
    }

    $scope.set_mode = function(m) {
      $scope.mode = m;
    }

    $scope.toggle_sample = function(sample) {
      if ( sample.open ) {
        sample.open = false;
      } else {
        treeAjax.subsamples(sample,function(data) {
          sample.subsamples = data;
          sample.open = true;     
        })
      }
    }

    $scope.edit_sample = function(sample) {
      sample.edit = true;
      sample.sample_type = $scope.sample_type_from_id(sample.sample_type_id);
    }

    $scope.view_sample = function(sample) {
      sample.edit = false;
    }    

    $scope.save_new_samples = function() {
      console.log("SAVE " + $scope.new_samples.length + " SAMPLE(S) FROM FORM.");
    }

    $scope.save_sample = function(sample) {
      console.log("SAVE SAMPLE: " + sample);
    }

    // Helper methods

    $scope.empty_sample = function(st,name) {
      return {
        sample_type: st,
        name: name ? name : "new-" + st.name.toLowerCase(),
        description: "Description of new " + st.name.toLowerCase() + " here",
        project: $scope.current_selection.project ? $scope.current_selection.project : $scope.projects[0].name
      };
    }

    $scope.fields = function(sample_type) {

      var field_names = aq.collect(aq.range(8),function(i) { 

        var type = sample_type["field"+(i+1)+"type"];

        if ( type != 'number' && type != 'string' && type != 'url' ) {
          type = type.split('|');
        }

        return { 
          index: i+1,
          name: sample_type["field"+(i+1)+"name"],
          type: type
        }

      });

      return aq.where(field_names,function(f) {
        return f.name != "" && f.name != "not used";
      });

    }

    $scope.sample_type_from_id = function(stid) {
      return aq.where($scope.sample_types,function(st) {
        return stid == st.id;
      })[0];
    }

    $scope.login = function(id) {
      var users = aq.where($scope.users,function(user) {
        return user.id == id;
      });
      if ( users.length == 1 ) {
        return users[0].login;
      } else {
        return "unknown";
      }
    }

  }]);

  w.directive("autocomplete", function() {

    samples_for = function(types) {
      var samples = [];
      aq.each(types,function(type) {
        samples = samples.concat(all_samples[type])
      });
      return samples;
    }

    return {
      restrict: 'A',
      scope: { autocomplete: '=', ngModel: '='  },
      link: function($scope,$element,$attributes) {
        var types = $scope.autocomplete;
        $element.autocomplete({
          source: samples_for(types),
          select: function(ev,ui) {
            $scope.ngModel = ui.item.value;
            $scope.$apply();
          }
        })
      }
    }

  });

  w.directive("projectcomplete", function() {

    return {
      restrict: 'A',
      scope: { ngModel: '=' },
      link: function($scope,$element,$attributes) {
        $element.autocomplete({
          source: aq.collect($scope.$parent.projects,function(p) { return p.name; }),
          select: function(ev,ui) {
            $scope.ngModel = ui.item.value;
            $scope.$apply();
          }
        });
      }
    }

  });  

})();
