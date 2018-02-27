(function() {

  var w = angular.module('aquarium'); 

  w.directive('customOnChange', function() {
    return {
      restrict: 'A',
      link: function (scope, element, attrs) {
        var onChangeFunc = scope.$eval(attrs.customOnChange);
        element.bind('change', function(event){
          var files = event.target.files;
          console.log("change")
          onChangeFunc(files);
        });       
        element.bind('click', function(){
          console.log("click");
          element.val('');
        });
        console.log("link", scope.$eval(attrs.customOnChange),element)        
      }
    }
  });

  w.directive('upload', function() {

    return {

      restrict: 'EA',
      transclude: true,
      scope: { record: '=', small: '=', jobid: "=", auto: "=" },
      replace: true,

      template: "<label>"
              + "  <span ng-if='record.uploading && !small'>Busy...</span>"
              + "  <span ng-if='!record.uploading && !small'>Upload</span>"
              + "  <span ng-if='record.uploading && small'>...</span>"
              + "  <span ng-if='!record.uploading && small'><ng-md-icon icon='file_upload' size='14'/></span>"              
              + "    <input type=file"
              + "      id='upload'"
              + "      file='upload'"
              + "      multiple"
              + "      style='display: none;'>"
              + "</label>",       

      link: function(scope,element,attrs) {

        $(element).find('#upload').fileupload({
          dataType: "json",
          url: "/json/upload.json?jobid="+scope.jobid,
          add: function(e,data) {
            data.submit();
            scope.record.uploading = true;
            AQ.update();
          },        
          done: function(e,data) {
            var da = scope.record.new_data_association();
            delete da.upload;
            da.upload = AQ.Upload.record(data.result);
            da.upload_id = data.result.id;
            da.job_id = scope.jobid;
            da.url = data.result.url;
            if ( scope.auto ) {
              da.save().then(da => {
                scope.record.uploading = false;
                scope.record.process_upload_complete();
                 AQ.update();
              });
            } else {
              scope.record.uploading = false;
              scope.record.process_upload_complete();
              AQ.update();  
            }
          }
        });

      }
    }

  });

  w.controller ('uploadDialogCtrl', [ '$scope', '$mdDialog', function($scope,$mdDialog) {

    $scope.close_dialog = function() {
      $mdDialog.hide();
    }

    $scope.is_image = function(record) {
      return record.upload_content_type.split("/")[0] == "image";
    }   


  }]);

  w.directive('uploadViewer', ['$mdDialog', function($mdDialog) {


    return {

      restrict: "EA",
      transclude: true,
      scope: { record: "=" },
      replace: true,

      template: $('#upload_viewer').html(),

      link: function(scope,element,attrs) {

        scope.show_dialog = function() {

          $mdDialog.show({
            template: $('#upload_viewer_dialog').html(),
            scope: scope,
            preserveScope: true,
            controller: 'uploadDialogCtrl'
          });

        }

      }

    }

  }]);

})();