AQ.User.current = function() {
  return AQ.post('/json/current',{});
}