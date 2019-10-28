AQ.Budget.record_getters.spent = function() {
  var budget = this;
  delete budget.spent;
  budget.spent = {};

  AQ.get("/budgets/" + budget.id + "/spent").then(response => {
    budget.spent = response.data;
    // AQ.update();
  });

  return budget.spent;
};

//
// Asynchronously returns a list of budget ids corresponding to the year, month and
// user_id given.
//
AQ.Budget.used = function(year, month, user_id = -1) {
  return AQ.get(`/invoices/budgets_used/${year}/${month}/${user_id}`).then(
    result => result.data
  );
};
