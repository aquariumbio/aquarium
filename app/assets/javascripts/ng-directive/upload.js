(function() {

  var w;

  try {
    w = angular.module('aquarium'); 
  } catch (e) {
    w = angular.module('aquarium', ['ngCookies','ui.ace']); 
  } 

  w.directive('customOnChange', function() {
    return {
      restrict: 'A',
      link: function (scope, element, attrs) {
        var onChangeFunc = scope.$eval(attrs.customOnChange);
        element.bind('change', function(event){
          var files = event.target.files;
          onChangeFunc(files);
        });       
        element.bind('click', function(){
          element.val('');
        });
      }
    }
  });

  w.directive('upload', function() {

    return {

      restrict: 'EA',
      transclude: true,
      scope: { record: '=' },
      replace: true,

      template: "<div id='da123'>"
              + "<label class='btn btn-default btn-file btn-mini btn-spanner' ng-disabled='record.uploading'>"
              + "<span ng-if='record.uploading'>Uploading...</span>"
              + "<span ng-if='!record.uploading'>Upload File</span>"              
              + "  <input type=file"
              + "    id='upload'"
              + "    file='upload'"
              + "    data-url='/json/upload.json'"
              + "    multiple"
              + "    style='display: none;'>"
              + "</label>",

      link: function(scope,element,attrs) {

        $(element).find('#upload').fileupload({
          dataType: "json",
          add: function(e,data) {
            data.submit();
            scope.record.uploading = true;
            AQ.update();
          },        
          done: function(e,data) {
            var da = scope.record.new_data_association();
            delete da.upload;
            da.upload = data.result;
            da.upload_id = data.result.id;
            da.url = data.result.url;
            scope.record.uploading = false;
            AQ.update();
          }
        });

      }
    }

  });

})();
