(function() {

  var w;

  try {
    w = angular.module('aquarium'); 
  } catch (e) {
    w = angular.module('aquarium', []); 
  } 

  w.controller('browserCtrl', [ '$scope', '$http', '$attrs', function ($scope,$http,$attrs) {

    $scope.views = {
      sample_type: {}, // not used, yet
      project: {},
      recent: {},
      create: {
        selected: true,
        samples: []
      },
      search: {},
      user: { current: { login: "All", id: 0 } }
    };

    $scope.helper = new SampleHelper($http);

    $scope.user = new User($http,function(user_info) {
      $scope.views.user.current = user_info.current;
      $scope.get_projects(function(){
        $scope.$apply();
      });      
    });

    $scope.everyone = { login: 'everyone', id: 0, name: "All Projects" };

    // Fetch data

    $scope.get_projects = function(promise) {
      $.ajax({
        url: '/browser/projects?uid=' + $scope.views.user.current.id
      }).done(function(response) {
        $scope.views.project = {
          projects: response.projects,
          loaded: true,
          selection: {}
        };
        $scope.projects = response.projects;
        if ( promise ) { promise(response.projects); }
      });
    }

    $http.get('/sample_types.json').
      then(function(response) {
        $scope.sample_types = response.data;
        $scope.sample_type_names = aq.collect(response.data,function(st) {
          return st.name;
        });
      });

    $scope.helper.autocomplete(function(sample_names) {
      $scope.sample_names = sample_names;
    });

    // View Selection

    $scope.browser_control_class = function(view) {
      var c = "browser-control";
      if ( $scope.views[view].selected ) {
        c += " browser-control-on";
      } 
      return c;
    }

    $scope.select_view = function(view) {
      for ( key in $scope.views ) {
        $scope.views[key].selected = false;
      }
      $scope.views[view].selected = true;
      if ( view == 'recent' ) {
        $scope.fetch_recent();
      }
    }

    $scope.choose_user = function(user) {
      if ( $scope.views.user.current.id != user.id ) {
        $scope.views.project.loaded = false;
        $scope.views.user.current = user;
        $scope.views.recent.samples = [];
        if ( $scope.views.recent.selected ) {
          $scope.fetch_recent();
        }                
        $scope.get_projects(function(plist) {
          $scope.$apply();
        });
      }
    }

    // Recent samples

    $scope.fetch_recent = function() {
      if ( !$scope.views.recent.samples || $scope.views.recent.samples.length == 0 ) {
        $scope.helper.recent_samples($scope.views.user.current.id,function(samples) {
          $scope.views.recent.samples = samples;
        });
      }
    }

    // Project browsing

    $scope.select_project = function(project) {
      $scope.views.project.selection = { project: project.name, sample_type: null };
    }    

    $scope.unselect_project = function(project) {
      if ( $scope.views.project.selection.project == project.name  ) {
        $scope.views.project.selection.project = null;
      }
    }    

    $scope.show_sample_type = function(project,st) {
      return project.sample_type_ids.indexOf(st.id) >= 0;
    }

    $scope.select_st = function(st) { 
      if ( $scope.views.project.selection.sample_type != st.id) {
        $scope.views.project.selection.loaded = false;
        $scope.views.project.selection.sample_type = st.id;
        $scope.views.project.samples = {};
        $scope.helper.samples($scope.views.project.selection.project,$scope.views.project.selection.sample_type,function(samples) {
          $scope.views.project.samples = samples;
          $scope.views.project.selection.loaded = true;
        });
      }
    }

    $scope.unselect_st = function(st) {
      if ( $scope.views.project.selection.sample_type == st.id ) {
        $scope.views.project.selection.sample_type = null;
      } 
    }    

    $scope.sample_type_from_id = function(stid) {
      return aq.where($scope.sample_types,function(st) {
        return stid == st.id;
      })[0];
    }    

    $scope.by_user = function(sample) {
      return !$scope.views.user.filter || sample.user_id == $scope.views.user.current.id;
    }    

    // Sample creation

    $scope.new_sample = function(st) {
      $scope.views.create.samples.push(new Sample($http).new(st.id,function() {
        $scope.select_view('create');
      }));
    }

    $scope.remove_sample = function(sample) {
      var i = $scope.views.create.samples.indexOf(sample);
      $scope.views.create.samples.splice(i,1);
    }        

    $scope.sample_type_from_name = function(name) {
      return aq.where($scope.sample_types,function(st) {
        return name == st.name;
      })[0];
    }

    $scope.save_new_samples = function() {
      $scope.errors = [];
      $scope.helper.create_samples($scope.views.create.samples,function(response) {
        if ( response.errors ) {
          $scope.errors = response.errors;
        } else {
          $scope.views.create.samples = [];
          $scope.views.recent.samples = [];
          $scope.choose_user($scope.user.current);
          $scope.select_view('recent');
          $scope.messages = aq.collect(response.samples,function(s) { return "Created sample " + s.id + ": " + s.name; });          
        }
      });
    }   

    // Search

    $scope.search = function() {

      var url = '/browser/search/'+$scope.views.search.query;

      if ( $scope.views.user.filter ) {
        url += "/" + $scope.views.user.current.id;
      }

      $http.get(url).
        then(function(response) {
          $scope.views.search.samples = aq.collect(response.data,function(s) {
            return new Sample($http).from(s);
          })
        });      
    }

    // Messages 

    $scope.dismiss_errors = function() {
      $scope.errors = [];
    }

    $scope.dismiss_messages = function() {
      $scope.messages = [];
    }    

    $scope.noteColor = function(note) {
      if ( note ) {
        return { background: "#" + string_to_color(note,40) }
      } else {
        return {}
      }
    }      

  }]);

})();
