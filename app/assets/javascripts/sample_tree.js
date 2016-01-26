
(function() {

  w = angular.module('tree',[]);

  w.config(['$locationProvider', function($locationProvider) {
    $locationProvider.html5Mode(true);
  }]);

  w.controller('treeCtrl', [ '$scope', '$http', '$attrs', '$location', function ($scope,$http,$attrs,$location) {

    function fetch(sid,then) {
      $http({
        url: '/sample_tree/' + sid + '.json',
        method: "GET",
        responseType: "json"
      }).then(function(result) {
        then(result.data);
      });
    }

    $scope.init = function(sid) {

      $scope.sid = sid;

      fetch($scope.sid,function(data) {
        $scope.sample_tree = data;
        $scope.sample_tree.open = true;
        $scope.sample_tree.expanded = true;
        $scope.current_project = $scope.sample_tree.sample.project;
        $scope.current_sample_type = $scope.sample_tree.sample.sample_type;        
        $scope.current_sample = $scope.sample_tree.sample;                
      })

      $http({
        url: '/sample_tree/samples.json',
        method: "GET",
        responseType: "json"
      }).then(function(result) {
        $scope.sample_types = result.data.sample_types;
        $scope.projects = result.data.projects;
        $scope.samples = result.data.samples;
      });

    }

    $scope.open = function(st) {

      st.open = true;

      if ( !st.expanded ) {
        fetch(st.sample.id,function(data) {
          st.parents = data.parents;
          st.open = true;
          st.expanded = true;
        })
      }

    }

    $scope.close = function(st) {
      st.open = false;
    }

    $scope.displayable = function(v) {
      return v && typeof(v) != "object";
    }

    $scope.is_url = function(v) {
      var u = v;
      return typeof(u) == "string" && u.match(/^http/) != null;
    }

    function fetch_jobs(iid,then) {
      $http({
        url: '/sample_tree/jobs/' + iid + '.json',
        method: "GET",
        responseType: "json"
      }).then(function(result) {
        then(result.data);
      });
    }

    $scope.open_item = function(i) {
      i.open = true;
      if ( !i.expanded ) {
        fetch_jobs(i.id,function(jobs) {
          i.jobs = jobs;
          i.open = true;
          i.expanded = true;
        })
      }      
    }  

    $scope.close_item = function(i) {
      i.open = false;
    }          

    $scope.range = function(n) {
      return new Array(n);
    }

    $scope.noteBlur = function(item) {
      $http({
        url: '/sample_tree/annotate/' + item.id + '/' + item.data.note + '.json',
        method: "GET",
        responseType: "json"
      }).then(function(result) {
        console.log(result.data)
      });
    }    

    $scope.noteColor = function(note) {
      if ( note ) {
        return { background: "#" + string_to_color(note,40) }
      } else {
        return {}
      }
    }       

    $scope.set_project = function(p) {
      $scope.current_project = p;
    }

    $scope.set_sample_type = function(st) {
      $scope.current_sample_type = st;
    }

    $scope.set_sample = function(s) {

      $scope.sample_tree = {};
      $scope.current_sample = s;
      $scope.sid = s.id;
      $scope.init(s.id);
      //aq.change_url("Aquarium: " + s.name, "/sample_tree/"+s.id);

      $location.url("/sample_tree/"+s.id);
      $location.replace();
      history.pushState(null, 'any', $location.absUrl());

    }    

  }]);

})();

