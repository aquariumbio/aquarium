function highlight_code() {
  $('pre').each(function(i, block) {
    hljs.highlightBlock(block);
    $(block).addClass("code-block");
  });
  $("#precondition").click(function() {
    if ( $(this).html() == "[show]" ) {
      $(this).html("[hide]");
      $($("pre")[0]).show();
    } else {
      $(this).html("[show]");
      $($("pre")[0]).hide();
    }
  });
  $("#protocol").click(function() {
    if ( $(this).html() == "[show]" ) {
      $(this).html("[hide]");
    $($("pre")[1]).show();
    } else {
      $(this).html("[show]");
      $($("pre")[1]).hide();      
    }
  });
}

function load_md(path) {
  $.ajax({
      url: path,
      success: function (data) {
        var md = window.markdownit().set({html: true})
        $('#aquadoc-content').empty().html(md.render(data));
        highlight_code();
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
  let tag = "<iframe class='lib-frame' src='libraries/" + name + ".html' scrolling='yes'></iframe>"
  $("#aquadoc-content").empty().append(tag);
}

function load_overview() {
  load_md("README.md");
}

function load_license() {
  load_md("LICENSE.md");
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
