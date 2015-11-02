(function() {

  var w;
  try {
    w = angular.module('folders'); 
  } catch (e) {
    w = angular.module('folders', ['puElasticInput']); 
  } 

  w.controller('foldersCtrl', [ '$scope','railsfolder','focus', function ($scope,railsfolder,focus) {

    railsfolder.index(function(data) {
      $scope.folders = data.folders;
      $scope.folders[0].open = true;
      $scope.current_folder = $scope.folders[0];
      $scope.contents($scope.current_folder);
    });

    railsfolder.sample_types(function(data) {
      $scope.sample_types = data;
    });

    railsfolder.workflows(function(data) {
      $scope.workflows = data;
    });    

    $.ajax({
      url: '/sample_list'
    }).done(function(samples) {
      $("#add-sample").autocomplete({
        source: samples
      });
    });

    $scope.select = function(thing) {
      $scope.selection = thing;
    }

    $scope.save = function(sample) {
      sample.saving = true;
      railsfolder.save_sample(sample,function(data) {
        if ( data.error ) {
          sample.error = data.error;
        } else {
          sample.unsaved = false;
        }
        sample.saving = false;
      });
    }

    $scope.save_new = function(sample) {
      sample.saving = true;
      railsfolder.new_sample($scope.current_folder,sample,function(data) {
        if ( data.error ) {
          sample.error = data.error;
        } else {
          sample.unsaved = false;
          sample.id = data.sample.id
        }
        sample.saving = false;
      });
    }    

    $scope.unsave = function(sample) {
      sample.unsaved = true;
      sample.selected = true;
    }

    $scope.revert = function(sample) {
      railsfolder.get_sample(sample.id,function(data) {
        sample.name = data.sample.name;
        sample.data = data.sample.data;
        sample.description = data.sample.description;
        sample.unsaved = false;
      });
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

    $scope.newSample = function(sample_type) {
      sample = { 
        name: "New sample", 
        data: {}, 
        sample_type_id: sample_type.id, 
        sample_type: { name: sample_type.name },
        open: true,
        unsaved: true
      };
      angular.forEach(sample_type.datatype,function(v,k) {
        sample.data[k] = null;
      });
      $scope.current_folder.samples.unshift(sample);
    }

    $scope.setCurrentFolder = function(f) {
      $scope.current_folder = f;
      $scope.contents(f);
    }

    $scope.openSample = function(s) {
      s.open = true;
      $scope.selection = s;      
    }

    $scope.closeSample = function(s) {
      s.open = false;
      $scope.selection = s;      
    }    

    $scope.includeThread = function(s,t) {
      return s.containing_thread_id != t.id && s.open;
    }

    $scope.get_thread_parts = function(sample,thread) {
      if ( !thread.parts ) {
        railsfolder.thread_parts(sample.id,thread.id,function(data) {
          thread.parts = data.parts;
        });
      }
    }

    $scope.openThread = function(s,t) {
      t.open = true;
      $scope.get_thread_parts(s,t);
    }

    $scope.closeThread = function(t) {
      t.open = false;
    }      

    $scope.openFolder = function(f) {
      f.open = true;
    }

    $scope.openWorkflow = function(workflow) {
      window.location = '/workflows/' + workflow.id;
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
 
    $scope.contents = function(f) {
      if ( ! f.samples || ! f.workflows ) {
        railsfolder.samples(f,function(data) {
          f.samples = data.samples;
          f.workflows = data.workflows;          
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

