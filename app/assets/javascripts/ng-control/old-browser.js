(function() {
 
  var w;

  try {
    w = angular.module('aquarium'); 
  } catch (e) {
    w = angular.module('aquarium', ['ngCookies']); 
  } 

  w.controller('oldBrowserCtrl', [ '$scope', '$http', '$attrs', function ($scope,$http,$attrs) {

    $scope.new_samples = [];
    $scope.sample_types = [];
    $scope.projects_info = {};
    $scope.samples = {};
    $scope.projects = {};    
    $scope.project_choice = "user";
    $scope.mode = "view";
    $scope.editing = false;
    $scope.sample_names = {};
    $scope.errors = [];
    $scope.messages = [];
    $scope.recent_samples = [];
    $scope.sample_type_choice = {};
    $scope.helper = new SampleHelper($http);

    $scope.samples_loaded = false;
    $scope.types_loaded = false;
    $scope.projects_loaded = false;

    $scope.current_selection = { project: null, sample_type: null, loaded: false };

    $http.get('/sample_types.json').
      then(function(response) {
        $scope.sample_types = response.data;
        $scope.types_loaded = true;
        $scope.sample_type_choice = $scope.sample_types[0];      
      }, function(response) {
        console.log("error: " + response);
      });

    $scope.helper.autocomplete(function(sample_names) {
      $scope.sample_names = sample_names;
      $scope.samples_loaded = true;      
    });

    $.ajax({
      url: '/browser/projects'
    }).done(function(plist) {
      $scope.project_info = plist;
      $scope.projects = $scope.project_info.user;
      $scope.projects_loaded = true;
    });

    $scope.new_sample = function() {
      $scope.new_samples.push(new Sample($http).new($scope.sample_type_choice.id,function() {
        $scope.mode = 'new';       
      }));
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
      $scope.helper.samples($scope.current_selection.project,$scope.current_selection.sample_type,function(samples) {
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

    $scope.save_new_samples = function() {
      $scope.errors = [];
      $scope.helper.create_samples($scope.new_samples,function(response) {
        if ( response.errors ) {
          $scope.errors = response.errors;
        } else {
          $scope.new_samples = [];
          $scope.messages = aq.collect(response.samples,function(s) { return "Created sample " + s.id + ": " + s.name; });
          upgraded_samples = aq.collect(response.samples,function(raw_sample) {
            return new Sample($http).from(raw_sample);
          });
          $scope.recent_samples = upgraded_samples.concat($scope.recent_samples);
          $scope.set_mode('recent');
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
        url: '/browser/annotate/' + sample.id + '/' + note + '.json',
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

    $scope.default_project = function() {
      return $scope.current_selection.project ? $scope.current_selection.project : $scope.projects[0].name;
    }

    $scope.empty_sample = function(st) {
      return new Sample($http).new();
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

    $scope.show_sample_type = function(project,st) {
      return project.sample_type_ids.indexOf(st.id) >= 0;
    }   

  }]);

})();
