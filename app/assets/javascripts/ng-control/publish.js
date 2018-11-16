(function() {

  var w = angular.module('aquarium'); 

  w.controller('publishCtrl', [ '$scope', '$http', 
                function (  $scope,   $http ) {


    AQ.init($http);
    AQ.update = () => { $scope.$apply(); }
    AQ.confirm = (msg) => { return confirm(msg); }

    $scope.status = {};

    function compare_members(a,b) {
      if ( a.record_type == b.record_type ) {
        return a.name == b.name ? 0 : +(a.name > b.name) || -1
      } else {
        if ( a.record_type == "OperationType" ) {
          return 1;
        } else {
          return 0;
        }
      }
    }

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
            members: aq.where(objects, o => o.category == name).sort(compare_members)
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
      error: null,
      attempts: []
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

    function select_components(categories) {
      console.log(categories)
      aq.each(categories, category => {
        aq.each(category, component => {
          console.log(component);
          let type = component.library ? "library" : "operation_type";
          let cat = aq.find($scope.categories, c => c.name == component[type].category);
          if ( cat ) {
            cat.open = true;
            let comp = aq.find(cat.members, m => m.name == component[type].name );
            if ( comp ) {
              comp.selected = true;
            }
          }
        })
      });
    }

    $scope.check_repo = function() {
      start_working();
      AQ.post("/publish/check_repo", $scope.config.github)
        .then(response => {
          console.log("response", response.data)
          if ( response.data.result == 'ok' ) {
            if ( response.data.repo_exists ) {
              let access_token = $scope.config.github.access_token;
              $scope.config = response.data.config;
              $scope.config.github.access_token = access_token;
              select_components(response.data.categories)
              $scope.state.update = true;
            } else {
              $scope.state.update = false;
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

    function make_attempt() {
      if ( $scope.state.attempts.length > 10 ) {
        $scope.state.attempts = [];
      }
      $scope.state.attempts.push(Date());
    }

    $scope.publish = function() {
      start_working();
      AQ.post("/publish/publish", { config: $scope.config, categories: selections() })
        .then(response => {
          console.log(response.data)
          if ( response.data.result == 'ok' ) {
            $scope.state.mode = 'submitted';
            $scope.state.repo = response.data.repo;
            $scope.state.worker_id = response.data.worker_id;
            console.log(`wid = ${$scope.state.worker_id}`);
            stop_working();
            make_attempt();
            check_progress();
          } else {
            $scope.state.error = response.data.message;
            $scope.state.details = response.data.error;
            stop_working();
          }
        })
        .catch(response => stop_working())
    }

    function check_progress() {
      $scope.state.building = true;
      setTimeout(check_for_config,1000);
    }

    function check_for_config() {
      make_attempt();

      let w = new AnemoneWorker($scope.state.worker_id);

      w.retrieve()
       .then(worker => {
         if ( worker.status == 'done' ) {
           $scope.state.building = false;
         } else {
           check_progress();
         }
         $scope.$apply();
       })
       .catch(error => {
         $scope.state.building = false;
         $scope.state.error = error;
         $scope.$apply();
       })

    }

  }]);

})();                    
