(function() {

  let w = angular.module('aquarium');

  w.config(['$locationProvider', function($locationProvider) {
      $locationProvider.html5Mode({ enabled: true, requireBase: false, rewriteLinks: false });
  }]);  

  w.controller('browserCtrl', [ '$scope', '$http', '$attrs', 'aqCookieManager', '$sce', '$window',
                     function (  $scope,   $http,   $attrs,   aqCookieManager,   $sce ,  $window ) {

    AQ.init($http);
    AQ.update = () => { $scope.$apply(); }
    AQ.confirm = (msg) => { return confirm(msg); }
    AQ.sce = $sce;

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
          samples: []
        },
        search: {
          selected: $scope.views.search.selected,
          query: $scope.views.search.query,
          sample_type: $scope.views.search.sample_type,
          project: $scope.views.search.project,
          project_filter: $scope.views.search.project_filter,          
          user: $scope.views.search.user,
          user_filter: $scope.views.search.user_filter,
          item_id: $scope.views.search.item_id
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

      aqCookieManager.put_object("browserViews", data);

    }

    $scope.views = aqCookieManager.get_object("browserViews");

    if ( !$scope.views || $scope.views.version != 2 ) {

      $scope.views = {
        version: 2,
        project: {
          loaded: false,
          selection: {}
        },
        recent: {
          selected: false
        },
        create: {
          selected: false,
          samples: []
        },
        search: {
          selected: true,
          user: -1,
          user_filter: true
        },
        sample_type: {
          selected: false,
          selection: {}
        },
        user: { current: { login: "All", id: 0 } }
      };

      cookie();

      $scope.messages = []

    } else {
      if ( !$scope.views.sample_type ) {
        $scope.views.sample_type = { selected: false };
      }
    }

    $scope.everyone = { login: 'everyone', id: 0, name: "All Projects" };

    function init() {

      $scope.helper = new SampleHelper($http);

      $scope.user = new User($http,function(user_info) {
        if ( $scope.views.search.user == -1 ) {
          $scope.views.search.user = user_info.current.login;
          $scope.search(0);
        }
        if ( !$scope.views.user.initialized ) {
          $scope.views.user.initialized = true;
          $scope.choose_user(user_info.current);
        } else {
          $scope.get_projects(function(){
            $scope.$apply();
          });      
        }
      });

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
        
      load_sample_names();   

      if ( $scope.views.search.user != -1 ) {
        $scope.search(0);
      }            

    }

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

    function load_sample_names() {

      $scope.helper.autocomplete(function(sample_names) {
        $scope.sample_names = sample_names;
      });

    }

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
          $scope.choose_user($scope.user.current);
          $scope.views.search.query = "";
          $scope.views.search.sample_type = "";
          $scope.views.search.user = $scope.user.current.login;
          $scope.select_view('search');
          $scope.search(0);
          $scope.messages = aq.collect(response.samples,function(s) { 
            return "Created sample " + s.id + ": " + s.name; 
          });    
          load_sample_names();
        }
      });
    }   

    $scope.copy = function(sample) {
      var ns = angular.copy(sample).wipe();
      $scope.views.create.samples.push(ns);
      $scope.select_view('create');
    }

    // Search

    $scope.search = function(p) {

      $scope.views.search.samples = [];
      $scope.views.search.status = "searching";
      $scope.views.search.page = p;

      $http.post("/browser/search",$scope.views.search).
        then(function(response) { 
          $scope.views.search.status = "preparing";         
          $scope.views.search.samples = aq.collect(response.data.samples,function(s) {
            var sample = new Sample($http).from(s);
            if ( aq.url_params().sid && sample.id === parseInt(aq.url_params().sid) ) {
              sample.open = true;
              sample.inventory = true;
              sample.loading_inventory = true;
              sample.get_inventory(function() {
                sample.loading_inventory = false;            
                sample.inventory = true;
              });              
            }
            return sample;
          });
          $scope.views.search.count = response.data.count;
          $scope.views.search.pages = aq.range(response.data.count / 30);
          $scope.views.search.status = "done";
        });
          
    }

    $scope.item_search = function() {
      AQ.Item.find($scope.views.search.item_id).then( item => {
        $scope.views.search.item = item;
        $scope.views.search.item.modal = true;
        $scope.views.search.item.new_location = $scope.views.search.item.location;
        cookie();
        AQ.update();
      }).catch(() => alert("Could not find item with id " + $scope.views.search.item_id));
    }
 

    $scope.page_class = function(page) {
      var c = "page";
      if ( page == $scope.views.search.page ) {
        c += " page-selected";
      }
      return c;
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

    $scope.upload_change = function(files) {
      $scope.spreadsheet_name = files[0].name;
      $scope.upload();      
    }

    $scope.upload = function() {

      $scope.spreadsheet_name = undefined;

      var f = document.getElementById('spreadsheet').files[0],
          r = new FileReader();

      r.onloadend = function(e) {

        try {

          data = $scope.helper.spreadsheet(
            $http,
            $scope.sample_types,
            $scope.sample_names,
            e.target.result
          );

          $scope.views.create.samples = data.samples;
          $scope.messages = data.warnings;
          $scope.messages.push("Spreadsheet '" + f.name + "' processed. Review the new samples below and click 'Save' to save this data to Aquarium.");
          $scope.select_view('create');

        } catch (e) {

          $scope.messages = [ "Error processing spreadsheet: " + e ];
          $scope.$apply();

        }

      }

      r.readAsText(f);

    }     

    $scope.openMenu = function($mdMenu, ev) {
      originatorEv = ev;
      $mdMenu.open(ev);
    };    

    if ( aq.url_params().sid ) {

      AQ.Sample.find(parseInt(aq.url_params().sid)).then(sample => {
        $scope.views.search.query = sample.identifier;
        $scope.views.search.sample_type = "";
        $scope.views.search.user_filter = false;
        $scope.views.search.project = "";
        $scope.views.search.project_filter = false; 
        $window.history.replaceState(null, document.title, "/browser");  
        cookie();
        init();

      }).catch(result => init())

    } else if ( aq.url_params().stid ) {

      AQ.SampleType.find(parseInt(aq.url_params().stid)).then(st => {
        $scope.views.search.query = "";
        $scope.views.search.sample_type = st.name;
        $scope.views.search.user_filter = false;
        $scope.views.search.project = "";
        $scope.views.search.project_filter = false; 
        $window.history.replaceState(null, document.title, "/browser");  
        cookie();
        init();     

      }).catch(result => init())        

    } else {
      init();
    }    

  }]);

})();
