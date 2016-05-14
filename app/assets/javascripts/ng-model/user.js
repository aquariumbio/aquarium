function User(http,promise) {
  this.http = http;
  this.init(promise);
}

User.prototype.get = function(url,f) {
  this.http.get(url).
    then(f, function(response) {
      console.log("error: " + response);
    });
}  

User.prototype.init_aux = function(users,current) {
  this.all     = User.prototype.all;        
  this.current = User.prototype.current;       
  this.logins  = User.prototype.logins;
}

User.prototype.init = function(promise) {

  var user = this;

  if ( ! User.prototype.initialized && ! User.prototype.ready ) {

    if ( promise ) {
      User.prototype.promises = [ { promise: promise, user: user } ];
    }

    User.prototype.initialized = true;

    user.get('/users.json',function(users) {
      user.get('/users/current.json',function(current) {

        User.prototype.all = users.data;        
        User.prototype.current = current.data;
        User.prototype.logins = [];
        aq.each(users.data,function(u) {
          User.prototype.logins[u.id] = u.login;
        });                              
        user.init_aux();
        User.prototype.ready = true;
        aq.each(User.prototype.promises,function(p) {
          p.user.init_aux();
          p.promise(p.user);
        })

      });
    });

  } else if ( ! User.prototype.ready ) {

    if ( promise ) {
      User.prototype.promises = User.prototype.promises.concat( { promise: promise, user: user } );
    }

  } else {

    user.init_aux();
    if ( promise ) {
      promise(user);
    }
    
  }

  return this;

}

