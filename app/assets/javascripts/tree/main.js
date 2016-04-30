(function() {

  var w;

  try {
    w = angular.module('aquarium'); 
  } catch (e) {
    w = angular.module('aquarium', []); 
  } 

  w.controller('treeCtrl', [ '$scope', '$http', '$attrs', 'treeAjax', function ($scope,$http,$attrs,treeAjax) {

    // Initialization

    $scope.new_samples = [];
    $scope.sample_types = [];
    $scope.projects_info = {};
    $scope.samples = {};
    $scope.projects = {};    
    $scope.project_choice = "user";
    $scope.mode = "view";
    $scope.editing = false;
    $scope.users = [];
    $scope.current = {};
    $scope.logins = [];
    $scope.sample_names = {};
    $scope.errors = [];
    $scope.messages = [];
    $scope.recent_samples = [];
    $scope.sample_type_choice = {};

    $scope.samples_loaded = false;
    $scope.types_loaded = false;
    $scope.projects_loaded = false;

    $scope.current_selection = { project: null, sample_type: null, loaded: false };

    treeAjax.sample_types(function(data) {
      $scope.sample_types = data;
      aq.each($scope.sample_types,function(st) {
        st.fields = $scope.fields(st);
      });
      $scope.types_loaded = true;
      $scope.sample_type_choice = $scope.sample_types[0];
    });

    treeAjax.user_info(function(users,current) {
      $scope.users = users;
      $scope.current_user = current;
      aq.each($scope.users,function(user) {
        $scope.logins[user.id] = user.login;
      });
    });

    $.ajax({
      url: '/tree/all'
    }).done(function(sample_names) {
      $scope.sample_names = sample_names;
      $scope.samples_loaded = true;
    });    

    $.ajax({
      url: '/tree/projects'
    }).done(function(plist) {
      $scope.project_info = plist;
      $scope.projects = $scope.project_info.user;
      $scope.projects_loaded = true;
    });

    // Button methods

    $scope.new_sample = function() {
      $scope.new_samples.push($scope.empty_sample($scope.sample_type_choice));
      $scope.mode = 'new';
    }

    $scope.new_sub_sample = function(sample,index,st_name) {
      var st = $scope.sample_type_from_name(st_name);
      var f = 'field'+index;
      sample.copy[f].new = new Sample().empty(st,$scope.default_project());
      //sample.copy[f].new.edit = true;
      sample.copy[f].new.copy.name = sample.copy.name + "-" + sample.field_name(index).toLowerCase() ;
      sample.copy[f].new.copy.description = "The " + sample.field_name(index).toLowerCase() + " for " + sample.copy.name;
    }

    $scope.remove_subsample = function(field) {
      field.new = null;
    }

    $scope.new_subsample_button_class = function(sample,st_name) {
      if ( sample && sample.sample_type.name == st_name ) {
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
      $scope.samples[$scope.current_selection.project] = {};
      treeAjax.samples($scope.current_selection.project,$scope.current_selection.sample_type,function(samples) {

        var upgraded_samples = aq.collect(samples,function(raw_sample) {
          return new Sample().from(raw_sample);
        });

        $scope.samples[$scope.current_selection.project][$scope.current_selection.sample_type] = upgraded_samples;
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
          var key;
          sample.subsamples = {};
          for ( key in data ) {
            if ( typeof data[key] == "object" ) {
              sample.subsamples[key] = new Sample().from(data[key]);              
            } else {
              sample.subsamples[key] = data[key];
            }
          }
          sample.open = true;
        })
      }

    }

    $scope.edit_sample = function(sample) {
      sample.sample_type = $scope.sample_type_from_id(sample.sample_type_id);
      sample.edit = true;
      $scope.editing = true;
      sample.prepare_copy();
    }

    $scope.view_sample = function(sample) {      
      sample.edit = false;
      $scope.editing = false;
    }    

    $scope.save_new_samples = function() {
      console.log("SAVE " + $scope.new_samples.length + " SAMPLE(S) FROM FORM.");
      $scope.errors = [];
      treeAjax.save_new_samples($scope.new_samples,function(response) {
        if ( response.errors ) {
          $scope.errors = response.errors;
        } else {
          $scope.new_samples = [];
          $scope.messages = aq.collect(response.samples,function(s) { return "Created sample " + s.id + ": " + s.name; });
          upgraded_samples = aq.collect(response.samples,function(raw_sample) {
            return new Sample().from(raw_sample);
          });
          $scope.recent_samples = $scope.recent_samples.concat(upgraded_samples);
          $scope.set_mode('recent');
        }
      });
    }

    $scope.save_sample = function(sample) {
      treeAjax.save_sample(sample,function(response) {
        if ( response.errors ) {
          $scope.errors = response.errors;
        } else {
          $scope.messages = [ "Saved changes to sample " + sample.id + ": " + sample.name ]
          var new_sample = new Sample().from(response.sample);
          sample.edit = false;
          $scope.editing = false;
          sample.project = new_sample.project;
          sample.description = new_sample.description;
          for ( var i=1; i<=8; i++ ) {
            sample['field'+i] = new_sample['field'+i]
          }
        }
      });
    }

    $scope.dismiss_errors = function() {
      $scope.errors = [];
    }

    $scope.dismiss_messages = function() {
      $scope.messages = [];
    }    

    $scope.noteBlur = function(sample) {
      var note;

      if ( sample.data.note == "" ) {
        note = "_EMPTY_"
      } else {
        note = sample.data.note;
      }

      $http({
        url: '/tree/annotate/' + sample.id + '/' + note + '.json',
        method: "GET",
        responseType: "json"
      });

    }    

    $scope.noteColor = function(note) {
      if ( note ) {
        return { background: "#" + string_to_color(note,40) }
      } else {
        return {}
      }
    }  

    // Helper methods

    $scope.default_project = function() {
      return $scope.current_selection.project ? $scope.current_selection.project : $scope.projects[0].name;
    }

    $scope.empty_sample = function(st) {
      return new Sample().empty(st,$scope.default_project());
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

    $scope.sample_type_from_name = function(name) {
      return aq.where($scope.sample_types,function(st) {
        return name == st.name;
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

    $scope.allowed = function(sample) {
      var admin = aq.where($scope.current_user.groups,function(g) {
        return g.name == 'admin';
      });
      console.log([admin,$scope.current_user.id, sample.user_id]);
      return admin.length > 0 || $scope.current_user.id == sample.user_id;
    }

  }]);

  w.directive("autocomplete", function() {

    samples_for = function(names,types) {
      var samples = [];
      aq.each(types,function(type) {
        samples = samples.concat(names[type])
      });
      return samples;
    }

    return {
      restrict: 'A',
      scope: { autocomplete: '=', ngModel: '='  },
      link: function($scope,$element,$attributes) {
        var types = $scope.autocomplete;
        $element.autocomplete({
          source: samples_for($scope.$parent.sample_names,types),
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
