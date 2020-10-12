AQ.UserBudgetAssociation.record_getters.budget = function() {

  var uba = this;
  delete uba.budget;

  AQ.Budget.find(uba.budget_id).then(budget => {
    uba.budget = AQ.Budget.record(budget);
    AQ.update();
  });

  return {};

}
