AQ.User.current = function() {
  return new Promise(function(resolve,reject) {
    AQ.get('/json/current').then((response) => {
      resolve(response.data);
    });
  });
}

AQ.User.record_getters.url = function() {
  return "<a href='/users/" + this.id + "'>" + this.login + "</a>";
}