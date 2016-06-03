$(function() {

  function two_column_resize() { 
    var h = window.innerHeight - 59;
    $(".two-column-left").css('height',''+h+'px');
    $(".two-column-right").css('height',''+(h-10)+'px');
  }

  window.onresize = two_column_resize;

  two_column_resize();

});