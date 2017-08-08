(function() {

  var w = angular.module('aquarium'); 

  w.directive('download', function() {

    return {

      restrict: 'EA',
      transclude: true,
      scope: { model: '=' },
      replace: true,

      template: "<span href='#' ng-click='download()' class='download-link'>"
              + "  <span>{{model.upload_file_name}}</span>"
              + "</span>",       

      link: function($scope,$element,$attrs) {

        var downloading = false;

        $scope.download = function() {

          if ( !downloading ) {

            downloading = true;

            $scope.model.get_expiring_url().then(url => {

              var link = $("<a href='" + url + "' download id='upload_" + $scope.model.rid + "'>x</a>");
              $($element).append(link);
              var el = document.getElementById('upload_' + $scope.model.rid);
              el.click();
              $($element).empty().append("<span>" + $scope.model.upload_file_name + "</span>");
              downloading = false;

            })  

          }

        }

      }
    }

  });

  w.directive('downloadimage', function() {

    return {

      restrict: 'EA',
      transclude: true,
      scope: { model: '=' },
      replace: true,

      template: "<div></div>",       

      link: function($scope,$element,$attrs) {

        console.log("fetching image")

        $scope.model.get_expiring_url().then(url => {

          var img = $("<image src='" + url + "'></a>");
          $($element).append(img);
          console.log("fetched");

        })  

      }

    }

  });  

})();
