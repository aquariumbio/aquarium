(function() {

  var w = angular.module('aquarium');

  w.controller('technicianCtrl', [ '$scope', '$http', '$attrs', '$cookies', '$sce',
                        function (  $scope,   $http,   $attrs,   $cookies,   $sce ) {

    AQ.init($http);
    AQ.update = () => { $scope.$apply(); }
    AQ.confirm = (msg) => { return confirm(msg); }

    let job_id = parseInt(aq.url_path()[2]);

    $scope.uploads = {}; // Change this to get data from the server about all uploads associated with teh job so far

    $scope.selects = [];

    AQ.Job.find(job_id).then(job => {
      $scope.job = job;
      // these should be moved to the model   V
      $scope.job.state = JSON.parse($scope.job.state);
      make_backtrace();
      $scope.state.index = $scope.backtrace.length - 1;
      $scope.$apply();
    })

    $scope.state = {
      index: 0
    };

    make_backtrace = function() {
      $scope.backtrace = [];
      for ( var i=1; i<$scope.job.state.length/2+3; i+=2) {
        $scope.backtrace.push({
          display: $scope.job.state[i],
          response: $scope.job.state[i+1]
        })
      }
    }

    $scope.is_complete = function() {
      return $scope.backtrace[$scope.backtrace.length-1].display.operation == 'complete'
    }

    $scope.content_type = function(line) {
      var type = Object.keys(line)[0];
      return type;
    };

    $scope.table_input = function(cell,response) {
      let x = aq.where(response.inputs.table_inputs, input => input.opid == cell.operation_id && input.key == cell.key)[0].value;
      return x;
    }

    $scope.content_value = function(line) {
      var k = Object.keys(line)[0];
      if ( typeof line[k] === "string" ) {
        return $sce.trustAsHtml(line[k]);
      } else {
        return line[k];
      }
    };

    $scope.table_class = function(cell) {
      var c = "";
      if ( cell == null ) {
        c += " td-null-cell";
      } else if ( cell.class ) {
        c += cell.class;
      }
      if ( cell && cell.check ) {
        c += " td-check"
      }
      if ( cell && cell.type ) {
        c += " td-input"
      }
      return c;
    };

    $scope.keyDown = function(evt) {

      switch(evt.key) {

        case "ArrowLeft":
        case "ArrowUp":
          if ( $scope.state.index > 0 ) {
            $scope.state.index--;
          }
          break;
        case "ArrowRight":
        case "ArrowDown":
          if ( $scope.state.index < $scope.backtrace.length - 1 ) {
            $scope.state.index++;
          }
          break;

        default:

      }

    }

    $scope.start_upload = function(varname) {

      $("#upload-"+varname).click();
      $scope.upload_varname = varname;      

    }

    function send_file(file) {

      var r = new FileReader();

      file.status = "loading";
      file.percent = 0;

      if ( ! $scope.uploads[$scope.upload_varname] ) {
        $scope.uploads[$scope.upload_varname] = [];
      }

      $scope.uploads[$scope.upload_varname].push(file);

      $scope.$apply();

      r.onprogress = function(e) {
        file.progress = e;
        $scope.$apply();
      }

      r.onload = function(e) {

        var data = e.target.result;
        var fd = new FormData();
        var uri = "/krill/upload";
        var xhr = new XMLHttpRequest();

        file.status = "sending";
        $scope.$apply();
        
        xhr.open("POST", uri, true);

        xhr.onreadystatechange = function() {
            if (xhr.readyState == 4 && xhr.status == 200) {
                console.log(xhr.responseText); 
                var upload = AQ.Upload.record(JSON.parse(xhr.responseText));
                console.log(upload)
                $scope.job.uploads.push(upload)
                file.status = "complete";
                $scope.$apply();
            }
        };

        fd.append('file', file)
        fd.append('authenticity_token', $("#authenticity_token").val());
        fd.append('job', $scope.job.id)
        xhr.send(fd);          

      }

      r.readAsBinaryString(file);         

    }

    $scope.complete_upload = function(files) {

      for ( var i=0; i<files.length; i++ ) {      
        send_file(files[i])
      }

    }

    $scope.ok = function() {

      // todo: Disable the OK button
  
      // $http.post("/krill/next?command=next&job="+$scope.job.id,{
      //   inputs: JSON.stringify({
      //     timestamp: Date.now()/1000,
      //     table_inputs: []
      //   })

      // }).then( response => {

      //   let result = response.data.result;

      //   if ( result.response == "ready" || result.response == "done" ) {

      //     $scope.job.state = response.data.state;
      //     make_backtrace();
      //     $scope.state.index++;

      //   } else {

      //     alert ( "The protocol is still preparing the next step. Please try clicking 'OK' again or reloading the page.")

      //   }

        // todo: enable the OK button

      // });

    }


  }]);

})();















