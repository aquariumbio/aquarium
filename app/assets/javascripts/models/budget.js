AQ.Budget.record_getters.spent = function() {

  var budget = this;
  delete budget.spent;
  budget.spent = {};

  AQ.get("/budgets/" + budget.id + "/spent").then(response => {
    budget.spent = response.data;
    // AQ.update();
  })

  return budget.spent;

}

