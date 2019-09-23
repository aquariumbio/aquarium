function PlanSetup($scope, $http, $attrs, $cookies, $sce, $window) {
  AQ.init($http);
  AQ.update = () => {
    $scope.$apply();
  };
  AQ.confirm = msg => {
    return confirm(msg);
  };
  AQ.sce = $sce;

  AQ.snap = 16;
  $scope.snap = AQ.snap;

  $scope.last_place = 0;
  $scope.plan = AQ.Plan.new_plan("Untitled Plan");

  $scope.ready = false;

  $scope.state = {
    sidebar: { op_types: false, plans: true },
    messages: [],
    saving: false
  };

  // Navigation /////////////////////////////////////////////////////////////////////////////////

  $scope.nav = {
    // TODO: consolidate with $scope.state
    sidebar: "plans",
    folder: { uc: true, unsorted: false }
  };

  $scope.sidebar_button_class = function(name) {
    let c = "sidebar-button no-highlight";
    if ($scope.nav.sidebar == name) {
      c += " sidebar-button-selected";
    }
    return c;
  };

  $scope.refresh_plan_list = function() {
    $scope.state.loading_plans = true;

    return AQ.Plan.where({ user_id: $scope.current_user.id })
      .then(plans => {
        $scope.plans = aq.where(plans, p => p.status != "template");
        $scope.templates = aq.where(plans, p => p.status == "template");
      })
      .then(() => AQ.Plan.get_folders($scope.current_user.id))
      .then(folders => {
        $scope.folders = folders;
        $scope.state.loading_plans = false;
        $scope.$apply();
      });
  };

  function choose_folder(p) {
    $scope.nav.folder = { uc: false, unsorted: false };
    if (p.folder) {
      $scope.nav.folder[p.folder] = true;
    } else if (p.status == "planning ") {
      $scope.nav.folder.uc = true;
    } else {
      $scope.nav.folder.unsorted = true;
    }
  }

  function load_plan_from_url() {
    return AQ.Plan.load(aq.url_params().plan_id)
      .then(plan => {
        $scope.plan = plan;
        choose_folder(plan);
        $window.history.replaceState(null, document.title, "/plans");
        $scope.$apply();
      })
      .then(() => AQ.User.find($scope.plan.user_id))
      .then(user => ($scope.current_user = user))
      .catch(e => {
        add_designer_message(
          `Could not load plan ${aq.url_params().plan_id} specified in URL`
        );
        console.log(e);
      });
  }

  // INITIALIZATION /////////////////////////////////////////////////////////////////////////////

  var start_time = new Date();

  AQ.User.active_users()
    .then(users => ($scope.users = users))
    .then(() => AQ.User.current())
    .then(user => {
      $scope.current_user = user;
      $scope.state.selected_user_id = user.id;
    })
    .then(() => $scope.refresh_plan_list())
    .then(() => AQ.get_sample_names())
    .then(() => AQ.Plan.where({ status: "system_template" }))
    .then(templates => ($scope.system_templates = templates))
    .then(() => AQ.OperationType.all_fast(true))
    .then(operation_types => {
      $scope.operation_types = aq.where(operation_types, ot => ot.deployed);
      AQ.OperationType.compute_categories($scope.operation_types);
      AQ.operation_types = $scope.operation_types;
    })
    .then(() => (aq.url_params().plan_id ? load_plan_from_url() : null))
    .then(() => ($scope.ready = true))
    .then(() => $scope.$apply())
    .then(() =>
      console.log(`Completed initialization in ${new Date() - start_time} ms`)
    );

  // END INITIALIZATION /////////////////////////////////////////////////////////////////////////

  $scope.select_user = function() {
    AQ.User.find($scope.state.selected_user_id)
      .then(user => ($scope.current_user = user))
      .then(() => $scope.refresh_plan_list())
      .catch(data => {
        console.log("Could not find user " + $scope.state.selected_user_id);
        console.log(data);
      });
  };
}
