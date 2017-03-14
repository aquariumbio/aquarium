(function() {

  var w;

  try {
    w = angular.module('aquarium'); 
  } catch (e) {
    w = angular.module('aquarium', ['ngCookies','ui.ace','ngMaterial'], [ '$rootScopeProvider', function($rootScopeProvider) { 
      // This is an apparently well known hack that prevents digest errors when recursively
      // rendering templates that nest more than 10 levels.
      $rootScopeProvider.digestTtl(25); 
    }]);
  } 

  w.controller('browserCtrl', [ '$scope', '$http', '$attrs', '$cookies', 
                     function (  $scope,   $http,   $attrs,   $cookies ) {

    function cookie() {

      var data = {
        version: $scope.views.version,
        project: { 
          loaded: false,
          selected: $scope.views.project.selected,
          selection: $scope.views.project.selection,
          samples: []
        },
        recent: {
          selected: $scope.views.recent.selected
        },
        create: {
          selected: $scope.views.create.selected,
          samples: [],
        },
        search: {
          selected: $scope.views.search.selected,
          query: $scope.views.search.query
        },
        sample_type: {
          selected: $scope.views.sample_type.selected,   
          selection: {
            name: $scope.views.sample_type.selection.name,
            id: $scope.views.sample_type.selection.id,
            offset: $scope.views.sample_type.selection.offset,
            samples: []
          }
        },
        user: $scope.views.user
      };

      $cookies.putObject("browserViews", data);

    }

    $scope.views = $cookies.getObject("browserViews");

    if ( !$scope.views || $scope.views.version != 1 ) {

      $scope.views = {
        version: 1,
        project: {
          loaded: false,
          selection: {}
        },
        recent: {
          selected: true
        },
        create: {
          selected: false,
          samples: []
        },
        search: {
          selected: false
        },
        sample_type: {
          selected: false,
          selection: {}
        },
        user: { current: { login: "All", id: 0 } }
      };

      cookie();

    } else {
      if ( !$scope.views.sample_type ) {
        $scope.views.sample_type = { selected: false };
      }
    }

    $scope.helper = new SampleHelper($http);

    $scope.user = new User($http,function(user_info) {
      if ( !$scope.views.user.initialized ) {
        $scope.views.user.initialized = true;
        $scope.choose_user(user_info.current);
      } else {
        $scope.get_projects(function(){
          $scope.$apply();
        });      
      }
    });

    $scope.everyone = { login: 'everyone', id: 0, name: "All Projects" };

    // Fetch data

    $scope.get_projects = function(promise) {
      $scope.views.project.loaded = false;      
      $.ajax({
        url: '/browser/projects?uid=' + $scope.views.user.current.id
      }).done(function(response) {
        $scope.views.project.projects = response.projects;
        $scope.views.project.loaded = true;
        $scope.projects = response.projects;
        if ( $scope.views.project.selection.sample_type ) {
          $scope.select_st({ id: $scope.views.project.selection.sample_type },true);
        }
        if ( promise ) { promise(response.projects); }
      });
    }

    $http.get('/sample_types.json').
      then(function(response) {
        $scope.sample_types = response.data;
        $scope.sample_type_names = aq.collect(response.data,function(st) {
          return st.name;
        });
        if ( $scope.views.sample_type.selected && $scope.views.sample_type.selection ) {
          get_samples($scope.views.sample_type.selection);
        }        
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
      cookie();      

      if ( view == 'recent' ) {
        $scope.fetch_recent();
      }

      if ( view == 'sample_type' && $scope.views.sample_type.selection ) {
        $scope.select_sample_type($scope.views.sample_type.selection);
      }

    }

    $scope.choose_user = function(user) {

      $scope.views.user.current = user;
      cookie();

      $scope.views.recent.samples = [];
      if ( $scope.views.recent.selected ) {
        $scope.fetch_recent();
      }                

      $scope.views.project.loaded = false;        
      $scope.get_projects(function(plist) {
        $scope.$apply();
      });

    }

    // Recent samples

    $scope.fetch_recent = function() {
      if ( !$scope.views.recent.samples || $scope.views.recent.samples.length == 0 ) {
        $scope.helper.recent_samples($scope.views.user.current.id,function(samples) {
          $scope.views.recent.samples = samples;
          $scope.views.recent.sample_types = aq.uniq(aq.collect(samples, function(s) {
            return s.sample_type_id;
          })); 
        });
      }
    }

    $scope.fetch_recent();

    // Project browsing

    $scope.select_project = function(project) {
      $scope.views.project.selection = { project: project.name, sample_type: null };
    }    

    $scope.unselect_project = function(project) {
      if ( $scope.views.project.selection.project == project.name  ) {
        $scope.views.project.selection.project = null;
        $scope.views.project.selection.sample_type = null;
      }
    }    

    $scope.show_sample_type = function(project,st) {
      return project.sample_type_ids.indexOf(st.id) >= 0;
    }

    $scope.select_st = function(st, force) { // within project navigator

      if ( $scope.views.project.selection.sample_type != st.id || force) {

        $scope.views.project.selection.loaded = false;
        $scope.views.project.selection.sample_type = st.id;
        $scope.views.project.samples = [];
        cookie();

        $scope.helper.samples($scope.views.project.selection.project,
                              $scope.views.project.selection.sample_type,
                              function(samples) {
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

    // Sample Type Chooser    

    function get_samples ( st ) {
      var user_str = "";
      if ( $scope.views.user.filter ) {
        user_str = "/" + $scope.views.user.current.id;
      }
      $http.get('/browser/samples/' + st.id + '/' + st.offset + user_str + '.json').
        then(function(response) {
          st.samples = [];
          new Sample($http)
          aq.each(response.data,function(s) {
            st.samples.push ( new Sample($http).from(s) );
          });
        });
    }

    $scope.offset = function(sign) {
      $scope.views.sample_type.selection.offset += sign * 30;
      $scope.views.sample_type.selection.samples = [];
      get_samples($scope.views.sample_type.selection);
      cookie();      
    }        

    $scope.select_sample_type = function(st) {
      $scope.views.sample_type.selection = st;
      if ( !st.offset ) {
        st.offset = 0;        
      }
      get_samples(st);
      cookie();       
    }    

    $scope.unselect_sample_type = function(st) {
      if ( $scope.views.sample_type.selection == st ) {
        $scope.views.sample_type.selection = null;
      } 
      cookie();      
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

    $scope.sample_type_from_id = function(id) {
      return aq.where($scope.sample_types,function(st) {
        return id == st.id;
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
          $scope.messages = aq.collect(response.samples,function(s) { 
            return "Created sample " + s.id + ": " + s.name; 
          });          
        }
      });
    }   

    $scope.copy = function(sample) {
      var ns = angular.copy(sample).wipe();
      $scope.views.create.samples.push(ns);
      $scope.select_view('create');
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
          });
          $scope.views.search.sample_types = aq
                .uniq(aq.collect($scope.views.search.samples, function(s) {
            return s.sample_type_id;
          }));
        });      

    }

    if ( $scope.views.search.query ) {
      $scope.search();
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

    $scope.noteBlur = function(sample) {

      var note;

      if ( !sample.data.note || sample.data.note == "" ) {
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

    $scope.button_heading_class = function(sample) {

      if ( sample.open ) {
        return "button-heading-open";
      } else {
        return "button-heading-closed";
      }

    }  

  }]);

})();
