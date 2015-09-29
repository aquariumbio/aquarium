(function() {

  w = angular.module('folders',[]);

  w.controller('foldersCtrl', [ '$scope','railsfolder','focus', function ($scope,railsfolder,focus) {

    railsfolder.index(function(data) {
      $scope.folders = data.folders;
      $scope.folders[0].open = true;
      $scope.current_folder = $scope.folders[0];
    });

    $.ajax({
      url: '/sample_list'
    }).done(function(samples) {
      $("#add-sample").autocomplete({
        source: samples
      });
    });

    $scope.addSample = function(f) {
      console.log("adding sample " + $('#add-sample').val() );
      $('#add-sample').val('');
    }

    $scope.setCurrentFolder = function(f) {
      $scope.current_folder = f;
      $scope.samples(f);
    }

    $scope.openFolder = function(f) {
      f.open = true;
    }

    $scope.closeFolder = function(f) {
      f.open = false;
    }

    $scope.newFolder = function() {
      railsfolder.newFolder($scope.current_folder,function(data) {
        if ( !$scope.current_folder.children ) {
          $scope.current_folder.children = [];
        }
        $scope.current_folder.children.push(data.folder);
        $scope.current_folder.open = true;
        $scope.current_folder = data.folder;
        focus('folder-name');
      });
    }

    $scope.renameFolder = function(f) {
      railsfolder.renameFolder(f);
    }

    function remove(p,f) {
      if ( ! p.children || p.children == null ) {
        return null;
      }
      for ( var n in p.children ) {
        if ( f == p.children[n] ) {
          p.children.splice(n, 1);
          return p;
        } else {
          var r = remove (p.children[n],f);
          if ( r ) {
            return r;
          } 
        }
      }
      return null;
    }

    $scope.deleteFolder = function(f) {
      confirm("Are you sure you want to delete the folder and all of its sub-folders? Other contents will not be deleted, but may be harder to find.");
      railsfolder.deleteFolder($scope.current_folder,function(data) {
        $scope.current_folder = remove($scope.folders[0],$scope.current_folder);      
      });
    }

    $scope.samples = function(f) {
      if ( ! f.samples ) {
        railsfolder.samples(f,function(data) {
          console.log(data)
          f.samples = data.samples;
        });
      }
    }

    function find(f,target) {

      if ( f == target ) {
        return []
      } else if ( f.children ) {
        for ( n in f.children ) {
          var p = find(f.children[n],target);
          if ( p ) {
            return [f.name].concat(p);
          }
        }
      }

      return null;

    }

    $scope.path = function(f) {
      for ( n in $scope.folders ) {
        var p = find($scope.folders[n],f);
        if ( p ) {
          return p;
        } 
      }
    }

  }]);

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

  }]);

  w.factory('focus', function($timeout, $window) {
    return function(id) {
      $timeout(function() {
        var element = $window.document.getElementById(id);
        if(element)
          element.focus();
      });
    };
  });

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

