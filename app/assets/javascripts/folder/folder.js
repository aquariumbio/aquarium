(function() {

  var w;
  try {
    w = angular.module('folders'); 
  } catch (e) {
    w = angular.module('folders', ['puElasticInput', 'cfp.hotkeys']); 
  } 

  w.controller('foldersCtrl', [ '$scope','folderAjax','threadBuilder','workflowManager','focus', 'hotkeys', 
                       function ($scope,  folderAjax,  threadBuilder,  workflowManager,  focus,   hotkeys) {

    folderAjax.index(function(data) {

      $scope.folders = data.folders;
      $scope.folders[0].open = true;
      $scope.current_folder = $scope.folders[0];
      $scope.contents($scope.current_folder);

      $scope.threadBuilder = threadBuilder;
      $scope.threadBuilder.init($scope);

      $scope.workflowManager = workflowManager;
      $scope.workflowManager.init($scope);   

      $scope.clipboard = null;

    });

    folderAjax.sample_types(function(data) {
      $scope.sample_types = data;
    });

    folderAjax.workflows(function(data) {
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
      sample.error = null;
      folderAjax.save_sample(sample,function(data) {
        if ( data.error ) {
          sample.error = data.error;
        } else {
          sample.unsaved = false;
        }
        sample.saving = false;
      });
    }

    $scope.save_new = function(sample,role) {
      sample.saving = true;
      sample.error = null;
      folderAjax.new_sample($scope.current_folder,sample,role,function(data) {
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
      $scope.selection = sample;
    }

    $scope.revert = function(sample) {
      folderAjax.get_sample(sample.id,function(data) {
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
      $scope.addSampleAux(f,sid);
    }

    $scope.addSampleAux = function(f,sid) {
      folderAjax.add_sample(sid,$scope.current_folder.id,function(data) {
        $scope.current_folder.samples.unshift(data.sample); 
        $('#add-sample').val('');
        $scope.selection = data.sample; 
      });
    }

    $scope.addWorkflow = function(f,wid) {
      folderAjax.add_workflow(wid,$scope.current_folder.id,function(data) {
        $scope.current_folder.workflows.unshift(data.workflow); 
        $scope.selection = data.workflow; 
      });      
    }

    $scope.newSampleTemplate = function(sample_type) {
      var sample = { 
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
      return sample;
    }

    $scope.newSample = function(sample_type) {
      $scope.current_folder.samples.unshift($scope.newSampleTemplate(sample_type));
    }

    $scope.setCurrentFolder = function(f) {
      $scope.current_folder = f;
      $scope.contents(f);
      $scope.selection = null;
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
        folderAjax.thread_parts(sample ? sample.id : null,thread.id,function(data) {
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

    $scope.closeFolder = function(f) {
      f.open = false;
    }

    $scope.newFolder = function() {
      folderAjax.newFolder($scope.current_folder,function(data) {
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
      folderAjax.rename_folder(f);
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

    $scope.removeSampleAux = function(sample) {
      folderAjax.remove_sample($scope.current_folder,sample, function(data) {
        var i = $scope.current_folder.samples.indexOf($scope.selection);
        if ( $scope.current_folder.samples[i+1] ) {
          $scope.selection = $scope.current_folder.samples[i+1];
        }
        $scope.current_folder.samples.splice(i,1);
      });
    }

    $scope.removeSample = function() {
      $scope.removeSampleAux($scope.selection);
    }

    $scope.removeWorkflow = function(workflow) {
      folderAjax.remove_workflow($scope.current_folder,workflow, function(data) {
        var i = $scope.current_folder.workflows.indexOf(workflow);
        if ( $scope.current_folder.workflows[i+1] ) {
          $scope.selection = $scope.current_folder.worfklows[i+1];
        }
        $scope.current_folder.workflows.splice(i,1);
      });
    }    

    $scope.deleteFolder = function(f) {
      confirm("Are you sure you want to delete the folder and all of its sub-folders? Other contents will not be deleted, but may be harder to find.");
      folderAjax.delete_folder($scope.current_folder,function(data) {
        $scope.current_folder = remove($scope.folders[0],$scope.current_folder);      
      });
    }

    $scope.remove = function() {

      var object = $scope.selection;

      if ( object && object.sample_type ) {
        $scope.removeSampleAux(object);
      } else if ( object && object.form ) {
        $scope.removeWorkflow(object);
      } else if ( object && object.children ) {
        
      } else {
        console.log("Pasting unknown object.")        
      }      

    }
 
    $scope.contents = function(f) {
      if ( f.special == "workflows" ) {
        folderAjax.workflows(function(data) {
          f.workflows = data;          
        });
      } else if ( ! f.samples || ! f.workflows ) {
        folderAjax.samples(f,function(data) {
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

    $scope.paste = function() {

      var object = $scope.clipboard;

      // I am embarrased by hjow I am figuring out what kind of object is
      // being pasted.
      if ( object && object.sample_type ) {
        $scope.addSampleAux($scope.current_folder,object.id);
      } else if ( object && object.form ) {
        $scope.addWorkflow($scope.current_folder,object.id);        
      } else if ( object && object.children ) {
        console.log("TODO: paste folder " + object.id);
      } else {
        console.log("Pasting unknown object.")
      }

    }

    // KEYBOARD SHORTCUTS
    hotkeys.add({
      combo: 'ctrl+c',
      description: 'Copy',
      callback: function() {
        if ( $scope.selection ) {
          $scope.clipboard = $scope.selection;
        } else {
          $scope.clipboard = $scope.current_folder;
        }
      }
    });

    hotkeys.add({
      combo: 'ctrl+v',
      description: 'Paste',
      callback: $scope.paste
    });

    hotkeys.add({
      combo: 'ctrl+d',
      description: 'Delete',
      callback: $scope.remove
    });    

    hotkeys.add({
      combo: 'ctrl+n',
      description: 'New Folder',
      callback: $scope.newFolder
    });

  }]);

  w.directive('tooltip', function(){

    return {

      restrict: 'A',

      link: function(scope, element, attrs) {

        var d1 = 1500, t1, 
            d2 = 500,  t2;

        $(element).mouseover(function(){

          t1 = setTimeout(function(){
            $(element).tooltip('show');
          },d1);

        }).mouseout(function(){

          clearTimeout(t1);
          t2 = setTimeout(function(){
            var isHover = $(element).is(":hover");
            if(isHover !== true){
              $(element).tooltip('hide').unbind('mouseenter mouseleave');
            }
          },d2);

        });

      }

    };

  });

})();

