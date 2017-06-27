AQ.User.current = function() {
  return new Promise(function(resolve,reject) {
    AQ.get('/json/current').then((response) => {
      resolve(AQ.User.record(response.data));
    });
  });
}

AQ.User.record_getters.url = function() {
  return "<a href='/users/" + this.id + "'>" + this.login + "</a>";
}

AQ.User.record_getters.user_budget_associations = function() {

  var user = this;

  delete user.user_budget_associations;
  //user.user_budget_associations = [];

  AQ.UserBudgetAssociation.where({user_id: user.id}).then(ubas => {
    user.user_budget_associations = aq.collect(ubas, uba => AQ.UserBudgetAssociation.record(uba));
    AQ.update();
  });

  return user.user_budget_associations;

}

AQ.User.active_users = function() {

  return new Promise(function(resolve, reject) {

    AQ.User.all({methods: [ "retired?" ]}).then( users => {

      var rval = aq.where(users, u => !u["retired?"]).sort((u1,u2) => {
        if (u1.login < u2.login) {
          return -1;
        } else if (u1.login > u2.login) {
          return 1;
        } else {
          return 0;
        }
      });

      resolve(rval);

    }).catch(response => reject(response.data.errors));

  });

}

AQ.User.record_methods.init_params = function(names) {

  var user = this;

  if ( !user.params ) {
    user.params = {};
  }

  aq.each(names, n => user.params[n] = { key: n} );

}

AQ.User.record_getters.parameters = function() {

  var user = this;
  delete user.parameters;

  AQ.Parameter.where({user_id: user.id}).then(plist => {
    user.parameters = plist;
    if ( !user.params ) { user.params = {} };
    aq.each(user.parameters,p => {
      user.params[p.key] = p;
    })
    AQ.update();
  })

  return user.parameters;

}

AQ.User.record_methods.save = function() {

  var user = this;

  delete user.parameters;
  user.parameters = [];
  for ( key in user.params ) {
    user.parameters.push(user.params[key]);
  }

  AQ.http.put("/users/"+user.id,user).then(result => {
    console.log(result)
  }).catch(response => alert(response.data.error));

}

AQ.User.record_methods.change_password = function() {

  var user = this;

  AQ.http.put('/users/password', user).then( response => {

    delete user.password;
    delete user.password_confirmation;

  }).catch( response => {

    alert(response.data.error);

  })

}


