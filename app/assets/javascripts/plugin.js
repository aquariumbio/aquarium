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

