function PlanSetup ( $scope,   $http,   $attrs,   $cookies,   $sce,   $window ) {

  AQ.init($http);
  AQ.update = () => { $scope.$apply(); }
  AQ.confirm = (msg) => { return confirm(msg); }
  AQ.sce = $sce;

  AQ.snap = 16;
  $scope.snap = AQ.snap;
  
  $scope.last_place = 0;
  $scope.plan = AQ.Plan.new_plan("Untitled Plan");

  $scope.ready = false;

  $scope.state = {
    sidebar: { op_types: false, plans: true },
    messages: []
  }

  // Navigation /////////////////////////////////////////////////////////////////////////////////

  $scope.nav = { // TODO: consolidate with $scope.state
    sidebar: "plans",
    folder: { uc: true, unsorted: false }
  }

  $scope.sidebar_button_class = function(name) {
    let c = "sidebar-button no-highlight";
    if ( $scope.nav.sidebar == name ) {
      c += " sidebar-button-selected"
    }
    return c;
  }

  // INITIALIZATION /////////////////////////////////////////////////////////////////////////////

  $scope.refresh_plan_list = function() {

    return AQ.Plan.where({user_id: $scope.current_user.id})
      .then(plans => {
        $scope.plans = aq.where(plans, p => p.status != 'template');
        $scope.templates = aq.where(plans, p => p.status == 'template');
        return AQ.Plan.get_folders($scope.current_user.id).then(folders => {
          $scope.folders = folders;
          $scope.state.loading_plans = false;
          $scope.$apply();
        });
    });

  }  

  function close_folders() {
    $scope.nav.folder = { uc: false, unsorted: false }
  }

  function get_plans_and_templates() {

    $scope.refresh_plan_list()
      .then(() => AQ.get_sample_names())
      .then(() => { 

      AQ.Plan.where({status: "system_template"}).then(templates => {

        $scope.system_templates = templates;

        if ( aq.url_params().plan_id ) {              
          AQ.Plan.load(aq.url_params().plan_id).then(p => {
            $window.history.replaceState(null, document.title, "/plans"); 
            $scope.plan = p;
            $scope.ready = true;
            close_folders();
            if ( p.folder ) {
              $scope.nav.folder[p.folder] = true;
            } else if ( p.status == 'planning ') {
              $scope.nav.folder.uc = true;
            } else {
              $scope.nav.folder.unsorted = true;
            }
            AQ.User.find(p.user_id).then(user => {
              $scope.current_user = user;
              $scope.$apply();        
            })
          }).catch(e => {
            add_designer_message(`Could not find plan ${aq.url_params().plan_id} specified in URL`);
            $scope.ready = true;
            $scope.$apply();            
          });
        } else {
          $scope.ready = true;
          $scope.$apply();
        }

      });

    });

  }

  AQ.User.active_users().then(users => {

    $scope.users = users;

    AQ.User.current().then((user) => {

      $scope.current_user = user;
      $scope.state.selected_user_id = user.id;

      AQ.OperationType.all_fast(true).then((operation_types) => {

        $scope.operation_types = aq.where(operation_types,ot => ot.deployed);
        AQ.OperationType.compute_categories($scope.operation_types);
        AQ.operation_types = $scope.operation_types;
        get_plans_and_templates();


      });
    });    

  });

  $scope.select_user = function() {

    AQ.User.find($scope.state.selected_user_id).then(user => {
      $scope.current_user = user;
      get_plans_and_templates();
    }).catch(data => {
      console.log("Could not find user " + $scope.state.selected_user_id);
      console.log(data)
    })

  }

}