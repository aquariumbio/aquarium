
function showhide() {

  $('.showhide').each(function() {


    var el = $(this);
    var content = $(el.html());

    var show = $('<a href="#"><i class="icon-chevron-down"></i></a>').click(function(e) {
      e.preventDefault();
      content.toggle();
      show.toggle();
      hide.toggle();
    });

    var hide = $('<a href="#"><i class="icon-chevron-up"></i></a>').click(function(e) {
      e.preventDefault();
      content.toggle();
      show.toggle();
      hide.toggle();
    });

    el.empty().append(show).append(hide).append(content);
    content.toggle();
    hide.toggle();

  });

}