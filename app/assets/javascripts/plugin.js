function Plugin() {
  this.path = aquarium_plugin_path;
}

Plugin.prototype.ajax = function(params,callback) {

  $.ajax({
    url: "/plugin/ajax?path=" + this.path,
    data: { params: JSON.stringify(params) },
    dataType: "json",
  }).done(function(result) {
    callback(result);
  });

}

Plugin.prototype.update = function() {
}

Plugin.prototype.period = function(dt) {
  var that = this;
  if ( dt > 0 ) {
    this.intervalID = setInterval(function(){that.update();}, dt);
  } else {
    window.clearInterval(this.intervalID);
  }
}