(function() {

  var w;
  try {
    w = angular.module('folders'); 
  } catch (e) {
    w = angular.module('folders', []); 
  } 

  w.controller('foldersCtrl', [ '$scope','railsfolder','focus', function ($scope,railsfolder,focus) {

    railsfolder.index(function(data) {
      $scope.folders = data.folders;
      $scope.folders[0].open = true;
      $scope.current_folder = $scope.folders[0];
      $scope.current_folder.samples = [];
    });

    $.ajax({
      url: '/sample_list'
    }).done(function(samples) {
      $("#add-sample").autocomplete({
        source: samples
      });
    });

    $scope.width = {
      chooser: 6,
      id: 60,
      name: 120,
      role: 120,
      fields: 120,
      created: 30,
      updated: 30,
      status: 30,
      blank: 100
    };

    $scope.unsave = function(sample) {
      sample.unsaved = true;
      sample.selected = true;
    }

    $scope.save_enabled = function() {
      if ( $scope.current_folder ) {
        var saveQ = false;
        angular.forEach($scope.current_folder.samples, function(s) {
          if ( s.selected && s.unsaved ) {
            saveQ = true;
          }
        });
        return saveQ;
      } else {
        return false;
      }
    }

    $scope.get_current_thread_parts = function(sample) {
      if ( !sample.current_thread.parts ) {
        railsfolder.thread_parts(sample.id,sample.current_thread.id,function(data) {
          sample.current_thread.parts = data.parts;
        });
      } 
    }

    $scope.expandSample = function(sample) {
      sample.expanded = true;
      $scope.get_current_thread_parts(sample);
    }

    $scope.unexpandSample = function(sample) {
      sample.expanded = false;
    }

    $scope.expandSampleFields = function(sample) {
      sample.fields_expanded = true;
    }

    $scope.unexpandSampleFields = function(sample) {
      sample.fields_expanded = false;
    }

    $scope.addSample = function(f) {
      var sid = $('#add-sample').val().split(":")[0];
      railsfolder.add_sample(sid,$scope.current_folder.id,function(data) {
        $scope.current_folder.samples.unshift(data.sample); 
        $('#add-sample').val(''); 
      });
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
      // Return a list of samples (and their associated threads) contained in the folder f
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

    $scope.range = function(n) {
      return new Array(n);
    };    

  }]);

})();

