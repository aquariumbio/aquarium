(function() {

  var w;

  try {
    w = angular.module('aquarium'); 
  } catch (e) {
    w = angular.module('aquarium', ['ngCookies','ui.ace','ngMaterial']); 
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

      template: "<label>"
              + "  <span ng-if='record.uploading'>Busy...</span>"
              + "  <span ng-if='!record.uploading'>Upload</span>"              
              + "    <input type=file"
              + "      id='upload'"
              + "      file='upload'"
              + "      data-url='/json/upload.json'"
              + "      multiple"
              + "      style='display: none;'>"
              + "</label>",       

      link: function(scope,element,attrs) {

        $(element).find('#upload').fileupload({
          dataType: "json",
          add: function(e,data) {
            console.log("ASD");
            data.submit();
            scope.record.uploading = true;
            AQ.update();
          },        
          done: function(e,data) {
            console.log("BSD");
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
