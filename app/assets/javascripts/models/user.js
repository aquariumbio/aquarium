AQ.User.current = function() {
  return new Promise(function(resolve,reject) {
    AQ.get('/json/current').then((response) => {
      resolve(response.data);
    });
  });
}