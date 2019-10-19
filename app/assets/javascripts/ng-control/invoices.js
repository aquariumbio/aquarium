(function() {

  var w = angular.module('aquarium'); 
  
  w.controller('invoicesCtrl', [ '$scope', '$http', '$attrs', '$cookies', '$sce', '$mdDialog', 
                      function (  $scope,   $http,   $attrs,   $cookies,   $sce,   $mdDialog ) {

    // Private methods 

    function refresh() {

      $scope.state.transactions = null;

      let user_id = $scope.current_user.is_admin && $scope.all_invoices ? -1 : $scope.current_user.id;

      AQ.Transaction
        .where_month(
                $scope.state.date.getMonth()+1, 
                $scope.state.date.getFullYear(),
                $scope.state.budget.id,
                user_id
              )
        .then(transactions => {
          $scope.state.transactions = transactions;
          let op_type_ids = aq.uniq(
              aq.collect(transactions, 
              t => t.operation.operation_type_id)
            );
          $scope.state.operation_types = aq.where(
            $scope.operation_types, 
            ot => op_type_ids.indexOf(ot.id) >= 0
          );
          $scope.state.summary = AQ.Transaction.summarize(transactions);
          $scope.$apply();
        })
        .then(() => AQ.Budget.used($scope.state.date.getFullYear(), 
                                   $scope.state.date.getMonth()+1, 
                                   user_id))
        .then(budget_ids => {
            $scope.state.budget_ids_used = budget_ids
        })
        .then(() => AQ.Transaction.get_logs($scope.state.transactions))
        .then(logs => {
          $scope.state.transaction_logs = logs;
          $scope.$apply();
        })

    }

    // UI Accessible methods

    $scope.update = function() {
      $scope.state.date = $scope.new_state.date;
      $scope.state.budget = aq.find($scope.budgets, b => b.id == $scope.new_state.budget_id);
      if ( ! $scope.state.budget ) {
         $scope.state.budget = { id: $scope.new_state.budget_id, name: "All Budgets"}
      }
      refresh();
    }

    $scope.showAlert = function(message) {
      $mdDialog.show(
        $mdDialog.alert()
          .parent(angular.element(document.body))
          .clickOutsideToClose(true)
          .title('Message from Aquarium')
          .textContent(message)
          .ariaLabel('Alert')
          .ok('Ok')
      );
    };

    $scope.apply_credit = function(event) {

      let transactions = aq.where($scope.state.transactions, t => t.checked);

      if ( transactions.length == 0 ) {
        $scope.showAlert("Select at least one transaction")
        return;
      }

      $mdDialog.show({
          template: $("#credit-dialog").html(),
          parent: angular.element(document.body),
          controller: CreditDialogController,
          targetEvent: event,
          locals: { transactions: transactions }
        })
        .then(result => AQ.Transaction.apply_credit(transactions, result.percent, result.message))
        .then(response => {
          if ( ! response.error ) {
            $scope.state.transactions = $scope.state.transactions.concat(response.transactions);
            $scope.state.transaction_logs = $scope.state.transaction_logs.concat(response.transaction_logs);
            $scope.showAlert("Credit Successfully Applied");
            aq.each(transactions, t => t.checked = false); 
          } else {
            $scope.showAlert("Error: " + response.error);
          }
                  
        })
        .catch(() => false);

    }

    // Sub-controllers

    function CreditDialogController($scope, $mdDialog, transactions) {

      $scope.credit = {
        message: "Explanation here",
        percent: 100,
        transactions: transactions,
        total: aq.sum(transactions, t => t.total)
      }
 
      $scope.cancel = function() {
        $mdDialog.cancel();
      };
  
      $scope.apply = function() {
        $mdDialog.hide($scope.credit);
      };

    }    

    CreditDialogController.$inject = ["$scope", "$mdDialog", "transactions"];

    // Initialization

    AQ.init($http);
    AQ.update = () => { $scope.$apply(); };
    AQ.confirm = (msg) => { return confirm(msg); };      
    
    $scope.all_invoices = aq.url_params().all == 'true'; 

    $scope.state = {
        date: new Date(2019, 10-1), // JS months are zero indexed
        budget: { id: -1, name: "All Budgets"}
    };

    $scope.new_state = {
        date: new Date(2019, 10-1),
        budget_id: -1
    };

    Promise.all([
        AQ.Budget.all(),
        AQ.OperationType.all(),
        AQ.User.current()
    ]).then(results => {
        $scope.budgets = results[0];
        $scope.operation_types = results[1];
        $scope.current_user = results[2];
    }).then( () => {
        refresh();
    })

  }]);

})();