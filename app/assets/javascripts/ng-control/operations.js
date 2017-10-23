
(function () {

  let w = angular.module('aquarium');

  w.controller('operationsCtrl', ['$scope', '$http', '$attrs', 'aqCookieManager', '$interval',
    function ($scope, $http, $attrs, aqCookieManager, $interval) {

      AQ.init($http);
      AQ.update = () => { $scope.$apply(); };
      AQ.confirm = (msg) => { return confirm(msg); };

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
            selected_user: null
          }
        }

        $interval(reload, 30000);

      }

      function init2() {
        if ($scope.current.operation_type !== null && $scope.current.status !== null) {
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

      init1();

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
              $scope.$apply();
              init2();

            });
          });
        });
      });

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
          operation_type: { id: $scope.current.operation_type.id },
          status: $scope.current.status,
          category_index: $scope.current.category_index,
          show_completed: $scope.current.show_completed,
          selected_user: $scope.current.selected_user,
          filter_user: $scope.current.filter_user
        });
      }

      $scope.select = function (operation_type, status, selected_ops, append = false) {

        if (!append) {
          $scope.current.operation_type = operation_type;
          $scope.current.status = status;
          $scope.current.category_index = $scope.categories.indexOf(operation_type.category);
          store_cookie();
          delete operation_type.operations;
        }
        delete $scope.jobs;

        var actual_status, options;

        if (status === 'pending_true') {
          actual_status = 'pending';
        } else if (status === 'waiting') {
          actual_status = ['pending', 'waiting'];
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
          aq.each(operations, op => {
            op.jobs = aq.collect(op.jobs, job => AQ.Job.record(job));
            op.field_values = aq.collect(op.field_values, fv => AQ.FieldValue.record(fv))
          });
          if (status === 'waiting') {
            operation_type.operations = aq.where(operations, op => { return (op.status === 'pending' && !op.precondition_value) || op.status === 'waiting' });
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
          if ($scope.current.operation_type
            && $scope.numbers[$scope.current.operation_type.id]
            && old_val !== $scope.numbers[$scope.current.operation_type.id][$scope.current.status]) {
            $scope.select($scope.current.operation_type, $scope.current.status, [])
          }
          $scope.$apply();
        });

      }

      $scope.choose = function (operation_type, status, val, job_id) {
        aq.each(operation_type.operations, operation => {
          if (operation.operation_type_id === operation_type.id && operation.status === status && (!job_id || operation.last_job.id === job_id)) {
            operation.selected = val;
          }
        });
      };

      $scope.batch = function (operation_type) {

        var ops = aq.where(operation_type.operations, op => op.selected);

        if (ops.length > 0) {
          operation_type.schedule(ops).then(() => {
            get_numbers().then(numbers => {
              $scope.numbers = numbers;
              $scope.select(operation_type, 'scheduled', ops);
              $scope.$apply();
            });
          });
        }

      };

      $scope.retry = function (operation_type) {

        var ops = aq.where(operation_type.operations, op => op.selected);

        aq.each(ops, op => {
          op.set_status("pending").then(op => {
            get_numbers().then(numbers => {
              $scope.numbers = numbers;
              $scope.select(operation_type, 'pending', ops);
              $scope.$apply();
            });
          });
        });

      };

      $scope.unschedule = function (operation_type, jid) {

        var ops = aq.where(operation_type.operations, op => op.selected && op.last_job.id === jid);

        if (ops.length > 0) {
          operation_type.unschedule(ops).then(() => {
            get_numbers().then(numbers => {
              $scope.numbers = numbers;
              $scope.select(operation_type, 'pending_true', ops);
              $scope.$apply();
            });
          });
        }

      };

      $scope.debug = function (operation_type, job_id) {

        $scope.debugging_job_id = job_id;

        var num = aq.where(operation_type.operations, op => op.last_job.id === job_id).length;

        $http.get("/krill/debug/" + job_id).then(response => {
          get_numbers().then(numbers => {
            $scope.numbers = numbers;
            aq.remove($scope.jobs, job_id);
            delete $scope.debugging_job_id;
            $scope.$apply();
          });
        })

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
        $scope.applying_user_filter = true;
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

    }]);

})();
