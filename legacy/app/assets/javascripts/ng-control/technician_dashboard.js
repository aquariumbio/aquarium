(function () {

  let w = angular.module('aquarium');

  w.controller('technicianDashboard', ['$scope', '$http', '$attrs', '$interval', '$mdDialog',
                        function ($scope,    $http,   $attrs,   $interval,   $mdDialog) {

      AQ.init($http);
      AQ.update = () => { $scope.$apply(); };
      AQ.confirm = (msg) => { return confirm(msg); };
      AQ.config.no_items_in_backtrace = true;

      $scope.operation_types = [];

      function category_index(c) {
        $scope.categories.indexOf(c);
      }

      function get_category(i) {
        $scope.categories[i];
      }

      function init1() {

        $scope.current = {
          status: 'scheduled',
          category_index: null,
          operations: [],
        }

        $interval(reload, 30000);

      }

      function get_numbers() {
        return AQ.OperationType.numbers($scope.current.selected_user, $scope.current.filter_user)
      }

      $scope.get_numbers = get_numbers;

      init1();

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

      function highlight_categories(numbers) {
        $scope.current.active = {};
        for ( var n in numbers ) {
          aq.each($scope.operation_types, operation_type => {
            if ( operation_type.id == n && numbers[n].scheduled > 0 ) {
              $scope.current.active[operation_type.category] = true;
              if ( !$scope.current.category_index ) {
                $scope.current.category_index = $scope.categories.indexOf(operation_type.category)
              }
            }
          })
        }
      }

      $scope.select_category = function(cat_index, status, selected_ops, append=false) {
        if (!append) {
          $scope.current.status = status;
          $scope.current.category_index = cat_index
          delete $scope.current.operations;
        }
        delete $scope.jobs;

        let operations = $scope.current.operations

        category = get_category(cat_index)
        let ot_ids = aq.where($scope.operation_types, ot => ot.category == $scope.categories[$scope.current.category_index]).map(ot => ot.id);
        console.log(ot_ids)
        // debugger;
        let criteria = {
          operation_type_id: ot_ids,
          status: 'scheduled'
        };
        // let options = {reverse: true};
        let options = {};

        AQ.Operation.manager_list(criteria, options).then(operations => {
          aq.each(operations, op => {
            op.jobs = aq.collect(op.jobs, job => AQ.Job.record(job));
            op.field_values = aq.collect(op.field_values, fv => AQ.FieldValue.record(fv))
          });
          $scope.current.operations = operations;
          aq.each(operations, op => {
            aq.each(selected_ops, sop => {
              if (op.id === sop.id) {
                op.selected = true;
              }
            })
          });

          jobs_with_duplicates = aq.collect(operations, op => {
            return op.jobs.length > 0 ? op.last_job : null
          });

          $scope.jobs = uniquify_by_id(jobs_with_duplicates);
          $scope.$apply();
        });
      }

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
              $scope.select_category($scope.current.category_index, $scope.current.status, $scope.current.operations)
              $scope.$apply();
            });
          });
        });
      });

      function uniquify_by_id(list) {
        results = []
        const map = new Map();
        for (const item of list) {
          if(!map.has(item.id)){
            map.set(item.id, true);
            results.push(item);
          }
        }
        return results;
      }

      $scope.more = function (status) {
        $scope.current.operation_type.list[status].offset += 10;
        $scope.select_category(scope.current.category_index, status, [], true);
      };

      function reload() {
        $scope.select_category($scope.current.category_index, $scope.current.status, [])
        get_running_jobs();        
      }

      $scope.choose = function (operation_type, status, val, job_id) {
        aq.each(operation_type.operations, operation => {
          if (operation.operation_type_id === operation_type.id && operation.status === status && (!job_id || operation.last_job.id === job_id)) {
            operation.selected = val;
          }
        });
      };

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
    }]);
})();
