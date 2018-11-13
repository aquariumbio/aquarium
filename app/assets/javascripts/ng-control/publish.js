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
        repo: "",
        access_token: ""
      }
    };

    $scope.state = {
      mode: "github",
      working: false,
      error: null
    }

    $scope.clear = function() {
      $scope.state.error = null;
      $scope.state.details = null;
      $scope.state.repo = null;
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
          console.log("response", response.data)
          if ( response.data.result == 'ok' ) {
            if ( response.data.repo_exists ) {
              $scope.config = JSON.parse(response.data.config);
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

    function selections() {
      return aq.collect(aq.where($scope.categories, c => $scope.has_selections()(c)), c => {
        return {
          name: c.name,
          members: aq.where(c.members, m => m.selected)
        }
      });
    }

    $scope.publish = function() {
      start_working();
      AQ.post("/publish/publish", { config: $scope.config, categories: selections() })
        .then(response => {
          console.log(response.data)
          if ( response.data.result == 'ok' ) {
            $scope.state.mode = 'submitted';
            $scope.state.repo = response.data.repo;
            stop_working();
            check_progress();
          } else {
            $scope.state.error = response.data.message;
            $scope.state.details = response.data.error;
            stop_working();
          }
        })
    }

    function check_progress() {
      $scope.state.building = true;
      setTimeout(check_for_config,10000);
    }

    function check_for_config() {
      AQ.post("/publish/ready", $scope.config.github)
        .then(response => {
          console.log("ready check", response.data)
          if ( response.data.ready ) {
            $scope.state.building = false;
          } else {
            check_progress();
          }
        });
    }

  }]);

})();                    
