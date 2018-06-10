(function() {

  var w = angular.module('aquarium'); 

  w.controller('developerCtrl', [ '$scope', '$http', '$attrs', 'aqCookieManager',
                        function ( $scope,   $http,   $attrs,   aqCookieManager ) {

    $scope.errors = [];
    $scope.messages = [];
    $scope.busy = false;
    $scope.jobs = [];
    $scope.mode = 'edit';
    $scope.editor = null;

    $scope.path = "";
    $scope.arguments = {};
    $scope.branch = "master";    

    $scope.aceLoaded = function(_editor) {
      _editor.setShowPrintMargin(false);
      $scope.editor = _editor;
    };

    function add_notice(m) {
      $scope.messages.push({ type: "notice", message: m});
    }

    function add_errors(errors) {
      $scope.messages = $scope.messages.concat(aq.collect(errors,function(e) {
        return { type: "error", message: e }
      }));  
    }

    $scope.get = function() {

      var path = $scope.path;

      $scope.cookie.path = $scope.path;
      $scope.cookie.arguments = $scope.arguments;
      $scope.cookie.branch = $scope.branch;  
      aqCookieManager.put_object("developer", $scope.cookie);

      if ( path == "" ) {
        path = "_NOT_SPECIFIED_";
      }

      $scope.busy = true;

      console.log("Getting " + $scope.path + " from " + $scope.branch);

      $http.post("/developer/get/", { path: $scope.path, branch: $scope.branch }).then(

        function(response) {
          if ( response.data.errors && response.data.errors.length > 0 ) {
            add_errors(response.data.errors);
            $scope.code = "";
          } else {
            $scope.sha = response.data.sha;
            $scope.code = response.data.content;
            add_notice("Version " + $scope.sha.substr($scope.sha.length - 7));
            $scope.editor.setValue($scope.code);
            $scope.editor.gotoLine(1);
          }
          $scope.busy = false;          
        },

        function(response) {
          add_errors(["Communication with server failed.", "" + response.status + ": " + response.statusText]);
          $scope.code = "";
          $scope.busy = false;
        }

      );

    }

    $scope.save = function() {

      if ( $scope.branch == 'master' ) {

        add_errors(["You cannot commit to the master branch from this page. You should commit to a branch, then do a pull request via github."]);

      } else if ( confirm("Are you sure you want to save this protocol?" ) ) {

        var path = $scope.path;

        if ( path == "" ) {
          path = "_NOT_SPECIFIED_";
        }

        $scope.cookie.branch = $scope.branch;  
        aqCookieManager.put_object("developer", $scope.cookie);
        $scope.busy = true;
        
        $http.post("/developer/save",{ path: $scope.path, content: $scope.editor.getValue(), branch: $scope.branch }).then(

          function(response) {
            if ( response.data.errors && response.data.errors.length > 0 ) {
              add_errors(response.data.errors);
            } else {
              $scope.sha = response.data.sha;
              add_notice("Saved. New version: " + $scope.sha.substr($scope.sha.length - 7));
            }
            $scope.busy = false;
          },

          function(response) {
            add_errors(["Communication with server failed.", "" + response.status + ": " + response.statusText]);
            $scope.code = "";
            $scope.busy = false;
          }

        );

      }

    }

    function highlight_syntax_error(errors) {
      var ses = aq.where(errors,function(e) {
        return e.match("syntax error");
      });
      if ( ses.length > 0 ) {
        var n = parseInt(ses[0].split(':')[1]);
        $scope.editor.gotoLine(n);
        $scope.editor.setHighlightGutterLine(true);
        $scope.mode = 'edit';
      }
    }

    $scope.test = function() {

      $scope.busy = true;   
      $scope.backtrace = [];
      $scope.code = $scope.editor.getValue();

      $http.post("/developer/test",{ path: $scope.path, arguments: $scope.arguments, branch: $scope.branch }).then(

        function(response) {
          if ( response.data.errors && response.data.errors.length > 0 ) {
            add_errors(response.data.errors.reverse());
            highlight_syntax_error(response.data.errors);
          } else {
            add_notice("Job id: " + response.data.job.id);
          }
          if ( response.data.job ) {
            $scope.jobs.unshift(response.data.job);
            $scope.backtrace = JSON.parse($scope.jobs[0].state);
          }          
          $scope.busy = false;
        },

        function(response) {
          add_errors(["Communication with server failed.", "" + response.status + ": " + response.statusText]);
          $scope.code = "";
          $scope.busy = false;
        }

      );

    }    

    $scope.control_class = function(m) {
      if ( m == $scope.mode ) {
        return "two-column-control two-column-control-on";
      } else {
        return "two-column-control";
      }
    }

    $scope.set_mode = function(val) {
      $scope.mode = val;
    }

    $scope.clear_messages = function() {
      $scope.messages = [];
    }

    $scope.message_class = function() {
      if ( $scope.messages.length > 0 && $scope.messages[$scope.messages.length-1].type == "error" ) {
        return "two-column-control two-column-control-no-click two-column-control-error";
      } else {
        return "two-column-control two-column-control-no-click ";
      }
    }

    $scope.has_inputs = function(step) {
      return Object.keys(step.inputs).length > 1;
    }

    $scope.content_type = function(line) {
      var type = Object.keys(line)[0];
      if ( type == "item") { console.log(type); }
      return type;
    }

    $scope.content_value = function(line) {
      var k = Object.keys(line)[0];
      return line[k];
    }      

    // Initialize 

    $scope.cookie = aqCookieManager.get_object("developer");

    if ( $scope.cookie && $scope.cookie.path ) {
      $scope.path = $scope.cookie.path;
      $scope.branch = $scope.cookie.branch;
      $scope.arguments = $scope.cookie.arguments;
      $scope.get();
    } else {
      $scope.cookie = { path: "", arguments: {}, branch: "master" };
      aqCookieManager.put_object("developer", $scope.cookie);
      $scope.path = "";
      $scope.arguments = {};
      $scope.branch = "master";
    }     

  }]);

})();