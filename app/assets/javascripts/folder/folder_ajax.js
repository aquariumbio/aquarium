(function() {

  var w;
  try {
    w = angular.module('folders'); 
  } catch (e) {
    w = angular.module('folders', ['puElasticInput']); 
  } 

  w.service('railsfolder', [ '$http', function($http) {

    this.get = function(url,f) {
      $http.get(url).
        then(f, function(response) {
          console.log("error: " + response);
        });
    }

    this.index = function(then) {
      this.get('/folders.json',function(response) {
        then(response.data);
      });
    };

    this.newFolder = function(parent,then) {
      this.get('/folders.json?method=new&parent_id='+parent.id,function(response) {
        then(response.data);
      });
    }

    this.deleteFolder = function(f,then) {
      this.get('/folders.json?method=delete&folder_id='+f.id,function(response) {
        then(response.data);
      });
    }    

    this.renameFolder = function(f) {
      this.get('/folders.json?method=rename&folder_id='+f.id+"&name="+f.name,function(response) {
      });     
    }

    this.samples = function(f,then) {
      this.get('/folders.json?method=contents&folder_id='+f.id,function(response) {
        then(response.data);
      });
    }

    this.thread_parts = function(sid,tid,then) {
      this.get('/folders.json?method=thread_parts&sample_id='+sid+'&thread_id='+tid,function(response) {
        then(response.data);
      });
    }

    this.add_sample = function(sample_id,folder_id,then) {
      console.log("here " + sample_id + ", " + folder_id);
      this.get('/folders.json?method=add_sample&sample_id='+sample_id+'&folder_id='+folder_id,function(response) {
        console.log("here response = " + response);
        then(response.data);
      });
    }    

  }]);

  ///////////////////////////////////////////////////////////////////////////////////////

  w.factory('focus', [ '$timeout', '$window', function($timeout, $window) {
    return function(id) {
      $timeout(function() {
        var element = $window.document.getElementById(id);
        if(element)
          element.focus();
      });
    };
  }]);

  w.directive('eventFocus', function(focus) {
    return function(scope, elem, attr) {
      elem.on(attr.eventFocus, function() {
        focus(attr.eventFocusId);        
      });
      scope.$on('$destroy', function() {
        elem.off(attr.eventFocus);
      });
    };
  });

})();

