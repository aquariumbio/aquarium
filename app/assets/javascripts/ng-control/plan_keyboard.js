function PlanKeyboard($scope,$http,$attrs,$cookies,$sce,$window) {

  function all_ops(f) {
    aq.each($scope.plan.operations,f);
  }  

  $scope.keyDown = function(evt) {

    switch(evt.key) {

      case "Backspace": 
      case "Delete":

        if ( $scope.current_wire ) {
          $scope.plan.remove_wire($scope.current_wire);
          $scope.current_wire = null;
        }
        if ( $scope.current_op && !$scope.current_fv ) {
          aq.remove($scope.plan.operations, $scope.current_op);                               
          $scope.plan.wires = aq.where($scope.plan.wires, w => {
            var remove = w.to_op == $scope.current_op || w.from_op == $scope.current_op;
            if ( remove ) {
              w.disconnect();
            }              
            return !remove;
          });
          $scope.current_op = null;
        }
        break;

      case "Escape":
        $scope.select(null);
        all_ops(op => op.multiselect = false)
        break;

      case "A":
      case "a":
        all_ops(op => op.multiselect = true );
        $scope.select(null);
        break


      default:

    }

  }    

}