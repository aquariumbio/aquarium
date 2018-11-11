(function() {

  var w = angular.module('aquarium'); 

  w.controller('publishCtrl', [ '$scope', '$http', 
                function (  $scope,   $http ) {


    AQ.init($http);
    AQ.update = () => { $scope.$apply(); }
    AQ.confirm = (msg) => { return confirm(msg); }

    $scope.status = {};

    function init() {

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

    }  

    init();

    $scope.config = {
      title: "My Workflow",
      description: "A workflow that does x, y and z",
      copyright: "My Organization",
      version: "0.0.1",
      authors: [
        {
          name: "First Last",
          affiliation: "A Place"
        }
      ],
      maintainer: {
        name: "",
        email: ""
      },
      acknowledgements: [
        {
          name: "First Last",
          affiliation: "A Place"
        }
      ],
      github: {
        user: "",
        repo: ""
      }
    };

    $scope.state = {
      mode: "build",
      working: false,
      error: null
    }

    function start_working() {
      $scope.state.working = true;
      $scope.state.error = null;
    }

    function stop_working() {
      $scope.state.working = false;
    }    

    $scope.set_selected = function(c,val) {
      aq.each(c.members, m => m.selected = val);
    }

    $scope.remove = function(list,el) {
      aq.remove(list,el)
    }

    $scope.check_repo = function() {
      start_working();
      AQ.post("/publish/check_repo", $scope.config.github)
        .then(response => {
          if ( response.data.result == 'ok' ) {
            if ( response.data.repo_exists ) {
              $scope.config = response.data.config;
            }
            $scope.state.mode = "build";            
          } else {
            $scope.state.error = response.data.message;
          }
          stop_working();       
        })
    }

    $scope.review = function() {
      $scope.state.mode = "review";
    }

    $scope.submit
     = function() {
      $scope.state.mode = "submitted";
    }    

    $scope.num_objects = function() {
      let n = 0;
      aq.each($scope.categories,c => aq.each(c.members, m => n += (m.selected ? 1 : 0)));
      return n;
    }

    $scope.has_selections = function() {
      return function(category) {
        r = false;
        aq.each(category.members, m => r = r || m.selected);
        return r;
      }
    }

  }]);

})();                    
