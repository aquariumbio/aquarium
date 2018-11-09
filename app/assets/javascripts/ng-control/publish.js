(function() {

  var w = angular.module('aquarium'); 

  w.controller('publishCtrl', [ '$scope', '$http', 
                function (  $scope,   $http ) {


    AQ.init($http);
    AQ.update = () => { $scope.$apply(); }
    AQ.confirm = (msg) => { return confirm(msg); }

    $scope.status = {};

    Promise.all([
      AQ.OperationType.where({deployed: true}),
      AQ.Library.all(),
      AQ.User.current()
    ]).then(results => {
      let names = [];
      let objects = results[0].concat(results[1]);
      $scope.user = results[2];
      $scope.config.maintainer.name = $scope.user.name;
      $scope.config.maintainer.email = $scope.user.email;
      aq.each(objects, x => names.push(x.category) );
      $scope.categories = aq.collect(aq.uniq(names).sort(), name => (
        { 
          open: false, 
          name: name,
          members: aq.where(objects, o => o.category == name).sort((a,b) => a.name == b.name ? 0 : +(a.name > b.name) || -1)
        }
      ));
      $scope.$apply();
    }).then(() => AQ.Parameter.where({user_id: $scope.user.id, key: "email"}))
      .then(plist => {
        if ( plist.length > 0 ) {
          $scope.config.maintainer.email = plist[0].value;
          $scope.$apply();
        }
      })
      .then(() => AQ.Parameter.where({user_id: $scope.user.id, key: "github_access_token"}))
      .then(plist => {
        if ( plist.length > 0 ) {
          $scope.config.github.access_token = plist[0].value;
          $scope.$apply();
        }
      });      

    $scope.config = {
      title: "My Workflow",
      description: "A workflow that does x, y and z",
      copyright: "My Organization",
      version: "0.0.1",
      authors: [
        {
          name: "",
          affilation: ""
        }
      ],
      maintainer: {
        name: "",
        email: ""
      },
      acknowledgements: [
        {
          name: "",
          affilation: ""
        }
      ],
      github: {
        user: "",
        repo: ""
      }
    };

    $scope.set_selected = function(c,val) {
      aq.each(c.members, m => m.selected = val);
    }

    $scope.remove = function(list,el) {
      aq.remove(list,el)
    }

  }]);

})();                    
