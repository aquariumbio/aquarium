var no_race = "init";

(function () {

  let w = angular.module('aquarium');

  w.controller('operationsCtrl', ['$scope', '$http', '$attrs', 'aqCookieManager', '$interval', '$mdDialog',
                        function ($scope,    $http,   $attrs,   aqCookieManager,   $interval,   $mdDialog) {

      AQ.init($http);
      AQ.update = () => { $scope.$apply(); };
      AQ.confirm = (msg) => { return confirm(msg); };
      AQ.config.no_items_in_backtrace = true;

      $scope.operation_types = [];

      function category_index(c) {
        $scope.categories.indexOf(c);
      }

      function init1() {

        let manager_state = aqCookieManager.get_object("managerState");
        if (manager_state) {
          $scope.current = manager_state;
          if ($scope.current.selected_user) {
            $scope.current.selected_user = AQ.User.record({
              id: $scope.current.selected_user.id,
              name: $scope.current.selected_user.name,
              login: $scope.current.selected_user.login,
            })
          }

        } else {
          $scope.current = {
            operation_type: null,
            status: null,
            category_index: 0,
            show_completed: false,
            filter_user: false,
            selected_user: null,
            switch_user: false,
            active_jobs: false,
            active: {},
            activity_report: { selected: false, date: new Date() }
          }
        }

        $scope.current.activity_report.data = [];

        $interval(reload, 30000);

      }

      function init2() {
        if ( $scope.current.activity_report.selected ) {
          $scope.get_job_report();
        } else if ( $scope.current.active_jobs ) {
          // CLICK ACTIVE JOBS BUTTON TO EXECUTE REACT CODE
          $('#active_jobs_button').click();
          console.log("Active jobs should be highlighted")
        } else if ( $scope.current.operation_type !== null && $scope.current.status !== null) {
          let operation_type = aq.find(AQ.operation_types, operation_type => operation_type.id === $scope.current.operation_type.id);
          if (operation_type) {
            $scope.current.category_index = $scope.categories.indexOf(operation_type.category);
            $scope.select(operation_type, $scope.current.status, []);
          } else {
            $scope.current.category_index = 0;
          }
        }
      }

      function get_numbers() {
        return AQ.OperationType.numbers($scope.current.selected_user, $scope.current.filter_user)
      }

      $scope.get_numbers = get_numbers;

      init1();

      get_tech_list();

      $scope.status = 'Loading Operation Types ...';

      AQ.OperationType.deployed_with_timing().then(operation_types => {
        $scope.status = "Fetching user information ...";
        AQ.User.current().then(user => {
          AQ.User.active_users().then(users => {
            $scope.users = users;
            get_numbers().then(numbers => {

              $scope.status = "Ready";
              AQ.operation_types = AQ.OperationType.sort_by_timing(operation_types);
              $scope.operation_types = AQ.operation_types;
              aq.each($scope.operation_types, operation_type => {
                operation_type.list = {
                  done: { offset: 0, limit: 10 },
                  error: { offset: 0, limit: 10 }
                };
                operation_type.timing = AQ.Timing.record(operation_type.timing);
              });
              $scope.categories = aq.uniq(aq.collect(operation_types, operation_type => operation_type.category)).sort();
              $scope.current_user = user;
              $scope.numbers = numbers;
              highlight_categories(numbers);
              $scope.$apply();
              init2();

            });
          });
        });
      });

      function get_running_jobs() {
        AQ.Job.where("pc >= 0", { include: [ { operations: { include: "operation_type" } }, "user" ] }).then(jobs => {
          AQ.http.get("/krill/jobs").then(response => {
            $scope.running_jobs = jobs.reverse();
            $scope.krill_job_ids = response.data.jobs;
          });
        });
      }

      get_running_jobs();

      $scope.status_selector = function (operation_type, status) {
        var selector = "";
        if ($scope.numbers[operation_type.id]) {
          if (!$scope.numbers[operation_type.id][status] || $scope.numbers[operation_type.id][status] === 0) {
            selector += " number-none";
          } else {
            selector += " number-some";
          }
          if ($scope.current.operation_type === operation_type && $scope.current.status === status) {
            selector += " number-selected"
          } else {
            selector += " number";
          }
        } else {
          selector += " number-none";
        }
        return selector;
      };

      function store_cookie() {
        aqCookieManager.put_object("managerState", {
          operation_type: { id: $scope.current.operation_type ? $scope.current.operation_type.id : null },
          status: $scope.current.status,
          category_index: $scope.current.category_index,
          show_completed: $scope.current.show_completed,
          selected_user: $scope.current.selected_user,
          filter_user: $scope.current.filter_user,
          active_jobs: $scope.current.active_jobs,
          activity_report: {
            selected: $scope.current.activity_report.selected,
            date: $scope.current.activity_report.date
          }
        });
      }

      function highlight_categories(numbers) {
        $scope.current.active = {};
        for ( var n in numbers ) {
          aq.each($scope.operation_types, operation_type => {
            if ( operation_type.id == n ) {
              if ( numbers[n].pending > 0 || numbers[n].scheduled > 0 || numbers[n].running > 0 ) {
                $scope.current.active[operation_type.category] = true;
              }
            }
          })
        }
      }

      $scope.toggle_show_completed = function() {
        // This is a hack. When you click the toggle switch, the ng-click method is called first.
        // After that, the md-switch directive changes the value of show_completed to reflect the
        // new switch state.
        $scope.current.show_completed = !$scope.current.show_completed;
        store_cookie();
        $scope.current.show_completed = !$scope.current.show_completed;
      }

      $scope.select_first_operation_type = function(cat_index) {
        $('#dashboard-container').hide()
        $('#content-container').show()

        $scope.category_index = cat_index;
        $scope.current.activity_report.selected = false;
        store_cookie();
        let ots = aq.where($scope.operation_types, ot => ot.category == $scope.categories[$scope.category_index]);
        if ( ots.length > 0 ) {
          $scope.select(ots[0],"waiting", [])
        }
      }

      $scope.select = function (operation_type, status, selected_ops, append = false) {
        no_race = "select"

        if (!append) {
          $scope.current.operation_type = operation_type;
          $scope.current.status = status;
          $scope.current.category_index = $scope.categories.indexOf(operation_type.category);
          $scope.current.active_jobs = false;
          $scope.current.activity_report.selected = false;
          store_cookie();
          delete operation_type.operations;
        }
        delete $scope.jobs;

        var actual_status, options;

        if (status === 'pending_true') {
          actual_status = 'pending';
        } else if (status === 'waiting') {
          actual_status = ['primed', 'waiting'];
        } else {
          actual_status = status;
        }

        if (status === "error" || status === "done") {
          options = { offset: operation_type.list[status].offset, limit: operation_type.list[status].limit, reverse: true };
        } else {
          options = {};
        }

        let criteria = {
          operation_type_id: operation_type.id,
          status: actual_status
        };

        if ($scope.current.filter_user && $scope.current.selected_user) {
          criteria.user_id = $scope.current.selected_user.id
        } else if (!$scope.current_user.is_admin) {
          criteria.user_id = $scope.current_user.id;
        }

        AQ.Operation.manager_list(criteria, options).then(operations => {
          // MANUALLY SET THE CATEGORY NAV
          // NOTE: NOT SETTING current.category_index = -1; IN app/views/operations/_sidebar.html.erb TO AVOID SCREEN FLASH
          //       AND WILL NOT SET CORRECLTY IF GOING BACK TO SAME VALUE
          $('#cat_'+$scope.current.category_index).removeClass("unselected-category").addClass("selected-category");

          aq.each(operations, op => {
            op.jobs = aq.collect(op.jobs, job => AQ.Job.record(job));
            op.field_values = aq.collect(op.field_values, fv => AQ.FieldValue.record(fv))
          });
          if (status === 'waiting') {
            operation_type.operations = aq.where(operations, op => { return (op.status === 'pending' && !op.precondition_value) || op.status === 'waiting' || op.status === 'primed' });
          } else if (status === 'pending_true') {
            operation_type.operations = aq.where(operations, op => op.status === "pending" && op.precondition_value);
          } else {
            if (append) {
              operation_type.operations = operation_type.operations.concat(operations);
            } else {
              operation_type.operations = operations;
            }
          }
          aq.each(operation_type.operations, op => {
            aq.each(selected_ops, sop => {
              if (op.id === sop.id) {
                op.selected = true;
              }
            })
          });
          
          $scope.jobs = aq.uniq(aq.collect(operation_type.operations, op => {
            return op.jobs.length > 0 ? op.last_job.id : null
          }));

          let job_assignments = new Object;
          aq.each(operation_type.operations, op => {
            if (op.jobs.length > 0 && op.last_job.assignment != null) {

              const assignment = { 
                assigned_to: op.last_job.assignment.assigned_to,
                to_name: op.last_job.assignment.to_name
              }
             job_assignments[op.last_job.id] == undefined ? job_assignments[op.last_job.id] = assignment : null
            }
          });
          $scope.job_assignments = job_assignments;

          $scope.applying_user_filter = false;
          $scope.$apply();
        })

      };

      $scope.more = function (status) {
        $scope.current.operation_type.list[status].offset += 10;
        $scope.select($scope.current.operation_type, status, [], true);
      };

      function reload() {

        var old_val;

        if ($scope.current.operation_type
          && $scope.current.operation_type && $scope.numbers[$scope.current.operation_type.id]) {
          old_val = $scope.numbers[$scope.current.operation_type.id][$scope.current.status];
        }

        get_numbers().then(numbers => {
          $scope.numbers = numbers;
          highlight_categories(numbers);
          if ($scope.current.operation_type
            && $scope.numbers[$scope.current.operation_type.id]
            && old_val !== $scope.numbers[$scope.current.operation_type.id][$scope.current.status]) {
            $scope.select($scope.current.operation_type, $scope.current.status, [])
          }
          $scope.$apply();
        });

        get_running_jobs();

      }

      $scope.choose = function (operation_type, status, val, job_id) {
        aq.each(operation_type.operations, operation => {
          if (operation.operation_type_id === operation_type.id && operation.status === status && (!job_id || operation.last_job.id === job_id)) {
            operation.selected = val;
          }
        });
      };

      $scope.batch = function (operation_type) {
        $('#batch-btn').prop('disabled', true);

        var ops = aq.where(operation_type.operations, op => op.selected);

        if (ops.length > 0) {
          operation_type.schedule(ops)
          .then(() => {
            get_numbers().then(numbers => {
              $scope.numbers = numbers;
              ops = aq.each(ops, op => {
                op.selected = false
              })
              $scope.select(operation_type, 'scheduled', ops);
              $scope.$apply();
            });
          })
        }       
      };

      $scope.retry = function (operation_type) {

        var ops = aq.where(operation_type.operations, op => op.selected);

        aq.each(ops, op => {
          op.set_status("pending").then(op => {
            for (var i = 0; i < op.outputs.length; i++) {
              op.outputs[i].item.mark_as_deleted()
              op.outputs[i].clear_item().save();
            }
            get_numbers().then(numbers => {
              $scope.numbers = numbers;
              $scope.select(operation_type, 'pending', ops);
              $scope.$apply();
            });
          });
        });

      };

      $scope.unschedule = function (operation_type) {
        $('#remove-btn').prop('disabled', true);

        var ops = aq.where(operation_type.operations, op => op.selected);

        if (ops.length > 0) {
          operation_type.unschedule(ops).then(() => {
            get_numbers().then(numbers => {
              $scope.numbers = numbers;
              ops = aq.each(ops, op => {
                op.selected = false
              })
              if (ops.length - aq.where(operation_type.operations, op => op.status === "scheduled").length > 0){
                $scope.select(operation_type, 'scheduled', ops);
              } else {
                $scope.select(operation_type, 'pending', ops);
              }
              $scope.$apply();
            });
          });
        }

      };

      $scope.debug = function (operation_type, job_id) {

        $scope.debugging_job_id = job_id;

        var num = aq.where(operation_type.operations, op => op.last_job.id === job_id).length;

        $http.get("/krill/debug/" + job_id)
          .then(response => get_numbers())
          .then(numbers => {
            $scope.numbers = numbers;
            aq.remove($scope.jobs, job_id);
            delete $scope.debugging_job_id;
            // $scope.$apply();
          });

      };

      $scope.timing_bullet = function (operation_type) {
        if (operation_type.timing) {
          return 'timing-bullet-' + operation_type.timing.status;
        } else {
          return 'timing-bullet-none';
        }
      };

      $scope.select_user = function () {
        store_cookie();
        reload();
      }

      $scope.step_all = function() {
        if ( confirm("Are you sure you want to force all operations to update? This can take a while and may load the server.")) {
          $scope.current.stepping = true;
          AQ.Operation.step_all().then(() => {
            reload();
            delete $scope.current.stepping;
          });
        }
      }

      $scope.category_class = function(index) {

        let c = "no-highlight";

        if ( $scope.current.category_index == index ) {
          c += ' selected-category';
        } else {
          c += ' unselected-category';
        }

        if ( $scope.current.active[$scope.categories[index]] ) {
          c += " active-category";
        }

        return c;

      }

      $scope.select_active_jobs = function() {
        $('#dashboard-container').show()
        $('#content-container').hide()
        if ( $('#dashboard-container').html().length == 0 ) {

          // BUILD FROM SCRATCH
          $.ajax({
            type: "GET",
            url: "/react",
            dataType: "html",

            success: function(response) {
              $('#dashboard-container').html(response)
            }
          })
        }

        $scope.current.active_jobs = true;
        $scope.current.activity_report.selected = false;
        store_cookie();
      }

      $scope.decrement_date = function() {
        $scope.current.activity_report.date = new Date($scope.current.activity_report.date);
        $scope.current.activity_report.date.setDate($scope.current.activity_report.date.getDate()-1);
        $scope.get_job_report();
      }

      $scope.increment_date = function() {
        $scope.current.activity_report.date = new Date($scope.current.activity_report.date);
        $scope.current.activity_report.date.setDate($scope.current.activity_report.date.getDate()+1);
        $scope.get_job_report();
      }

      $scope.get_job_report = function() {
        $('#dashboard-container').hide()
        $('#content-container').show()
        $scope.current.activity_report.data = new JobReport([], "waiting");
        AQ.get(`/jobs/report?date=${$scope.current.activity_report.date.toString()}`).then(reponse => {
          if (no_race == 'reports' || no_race == "init") {
            $scope.current.activity_report.data = new JobReport(reponse.data, "ready", $scope.current.activity_report.date);
            $scope.current.activity_report.selected = true;
            store_cookie();
          }
        })
      }
      
      function get_tech_list() {

        AQ.get('/api/v2/groups/technicians/users?options[]=job_count')
          .then(response => {
            $scope.current.technicians = response.data.data;
          });
      }

      $scope.assign_job = function (assign_to_id, to_name, job_id) {

        AQ.post(`/api/v2/jobs/${job_id}/assign?to=${assign_to_id}`, {})
          .then(function(response){
            $scope.job_assignments[job_id] = {
                assigned_to: assign_to_id,
                to_name: to_name
              }
            }, function(response){
              console.log("Error during job assignment: " + JSON.stringify(response.data.data))
            }
          );
      }

      $scope.unassign_job = function(job_id) {
        AQ.post(`/api/v2/jobs/${job_id}/unassign`, {})
        .then(function(response){
          $scope.job_assignments[job_id] = null
        },
          function(response){
            console.log("Error during job assignment: " + JSON.stringify(response.data.data))
        }); 
      }

      function get_job_assignment(job_id) {
        AQ.get(`/api/v2/jobs/${job_id}/assignment`)
        .then(response => {
          if (response.data.status === 200) {
            return response.data.data
          }
        });
      }

      $scope.disable_batch_button = function() {
        if ($scope.current.operation_type.operations) {
          // Enable button if a single operation has been selected
          return !$scope.current.operation_type.operations.some(operation => operation.selected == true)
        } else {
          return true
        }
      }

      $scope.disable_assign = function(techAssignment) {
        if (techAssignment == undefined) {
          return true;
        } else {
          return false;
        }
      }

      // Disable unassign button when there no assignment 
      $scope.disable_unassign = function(job_id) {
        if ($scope.job_assignments[job_id] == null || $scope.job_assignments[job_id] == undefined) {
          return true;
        } else {
          return false;
        }
      }

      // MANUALLY CLEAR THE CATEGORY NAV TO AVOID THE SCREEN FLASH WHEN CLICK { SOMETHING ELSE } > { ACTIVITY REPORTS }
      // USE INSTEAD OF current.category_index = -1; IN app/views/operations/_sidebar.html.erb
      $scope.clear_category_nav = function(nr) {
        no_race = nr;
        $('#cat_'+$scope.current.category_index).removeClass("selected-category").addClass("unselected-category");
      }

      
      
    }]);

})();


