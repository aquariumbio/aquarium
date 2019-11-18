AQ["Transaction"] = new AQ.Base("Account");
AQ["TransactionLog"] = new AQ.Base("AccountLog");


// Asynchronously returns the list of transactions for the given month, year,
// budget_id, and user_id.
//
AQ.Transaction.where_month = function(
  month,
  year,
  budget_id = -1,
  user_id = -1
) {
  let query = `MONTH(created_at) = ${month} AND YEAR(created_at) = ${year}`;
  let transactions = null;

  if (budget_id != -1) {
    query += ` AND budget_id = ${budget_id}`;
  }

  if (user_id != -1) {
    query += ` AND user_id = ${user_id}`;
  }
  // TODO: move query into rails controller/model 
  return AQ.Transaction.where(query, { include: ["user", "operation"] })
    .then(result => (transactions = result))
    .then(() =>
      AQ.PlanAssociation.where({
        operation_id: aq.collect(transactions, t => t.operation_id)
      },
      {
        include: ["plan"]
      })
    )
    .then(plan_associations => {
      aq.each(plan_associations, pa => {
        aq.each(transactions, t => {
          if (pa.operation_id == t.operation_id) {
            t.plan_id = pa.plan_id;
            t.plan_name = pa.plan.name;
          }
        });
      });
    })
    .then(() => 
        AQ.Parameter.where({
        user_id: aq.collect(transactions, t => t.user_id)
      })
    )
    .then(parameters => {
        aq.each(parameters, p => {
            aq.each(transactions, t => {
                if (p.user_id == t.user_id && p.key == "email") { 
                    t.email = p.value;
                }
            });
        });
        console.log("post user id code");
        console.log(transactions);
        return transactions; 
    });
};

/*

  Transaction math

  For debits:
    amount = raw cost
            = raw materials cost for material entries
            = labor_rate * labor_minutes for labor entries
    total cost = amount * ( 1 + markup_rate )

  For credits:
    amount = amount credited. labor_rate and markup_rate not used.

 */

// Total amount, including overhead
AQ.Transaction.record_getters.total = function() {
  if (this.transaction_type == "debit") {
    return this.amount * (1 + this.markup_rate);
  } else {
    return -this.amount;
  }
};

// Number of minutes of labor
AQ.Transaction.record_getters.labor_minutes = function() {
  // amount = labor_rate * labor_minutes
  if (this.category == "labor") {
    return this.amount / this.labor_rate;
  } else {
    return 0;
  }
};

// Cost of materials not including overhead
AQ.Transaction.record_getters.materials_base = function() {
  // amount = materials_base
  if (this.category == "materials") {
    return this.amount / (1 + this.markup_rate);
  } else {
    return 0;
  }
};

// Just the overhead portion
AQ.Transaction.record_getters.markup = function() {
  // overhead = total - amount
  return this.total - this.amount;
};

// Returns a summary of the costs associated with a list of transactions
AQ.Transaction.summarize_aux = function(transactions) {
  console.log("summarizing in transaction.js")
  let summary = {
    total: aq.sum(transactions, t => t.total),
    labor_minutes: aq.sum(transactions, t => t.labor_minutes),
    materials: aq.sum(transactions, t => t.materials_base),
    overhead: aq.sum(transactions, t => t.markup),
    additional_charges: 0, 
    // user_names: 
    // user_emails: 
  };

  return summary;
};

// Returns a summary of the costs associated with an operation type
AQ.Transaction.summarize_operation_type = function(
  transactions,
  operation_type_id
) {
  // TODO: eliminate where (?)
  let transaction_list = aq.where(
    transactions,
    t => t.operation.operation_type_id == operation_type_id
  );
  return AQ.Transaction.summarize_aux(transaction_list);
};

// Returns a summary of the transactions, and list of summaries for each operation type used.
AQ.Transaction.summarize = function(transactions) {
  let summary = AQ.Transaction.summarize_aux(transactions);
  let op_type_ids = aq.uniq(
    aq.collect(transactions, t => t.operation.operation_type_id)
  );

  summary.operation_type_summaries = [];
  for (var i in op_type_ids) {
    let id = op_type_ids[i];
    summary.operation_type_summaries[
      id
    ] = AQ.Transaction.summarize_operation_type(transactions, id);
  }

  return summary;
};

// Asynchronously returns all logs used in the list of transactions
AQ.Transaction.get_logs = function(transactions) {
  let transaction_ids = aq.collect(transactions, t => t.id);
  // TODO: eliminate where
  return AQ.TransactionLog.where(
    { row1: transaction_ids },
    { include: "user" }
  );
};
// 
// Asynchronously applies credits to the list of transactions, returning
// the resulting list of credit transactions and their logs
AQ.Transaction.apply_credit = function(transactions, percent, message) {
  let data = {
    rows: transactions,
    percent: percent,
    note: message
  };

  return AQ.post("/invoices/credit", data).then(result => {
    if (result.data.error) {
      throw result.data.error;
    } else {
      return {
        transactions: aq.collect(result.data.rows, t =>
          AQ.Transaction.record(t)
        ),
        transaction_logs: aq.collect(result.data.notes, l =>
          AQ.TransactionLog.record(l)
        )
      };
    }
  });
};
