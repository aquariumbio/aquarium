function load_md(path) {
  $.ajax(
    {
      url: path,
      success: function (data) {
        var md = window.markdownit().set({html: true})
        document.getElementById('content').innerHTML = md.render(data);
      }
    });
}

function load_operation_type(name) {
  load_md("operation_types/" + name + '.md');
}

function load_sample_type(name) {
  load_md("sample_types/" + name + '.md');
}

function load_object_type(name) {
  load_md("object_types/" + name + '.md');
}

function load_library(name) {

  $.ajax(
    {
      url: "libraries/" + name + '.rb',
      success: function (data) {
        let c = $("#content").empty().append($("<pre></pre>").append($("<code class='ruby'></code>").text(data)));
        c.each(function(i, block) {
          hljs.highlightBlock(block);

        });
      }
    });

}

function load_overview() {
  load_md("README.md");
}

$(function() {

  load_overview();

  $.ajax(
    {
      url: "config.json",
      success: function (data) {
        $("#title").text(data.title)
      }
    });

});
