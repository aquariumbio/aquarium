function Finder(kind) {

    var that = this;
    this.kind = kind;

    if ( kind == 'Samples' ) {

      this.fields = [ "project", "type", "sample" ];

    } else { // assume kind == 'Items'

      this.fields = [ "project", "type", "sample", "container", "item" ];

    } 

    this.launch_button = $('<button>'+kind+'</button>')
      .addClass('btn btn-small finder-btn')
	.click(function(){that.launch();});

    this.window = $('<div></div>').addClass('modal hide fade finder');
    $(document.body).append(this.window);

    return this.launch_button;

}

Finder.prototype.get = function(index,spec) {

    var that = this;
    var field = this.fields[index];

    // clear this and higher fields 
    for ( var i=index; i<=this.fields.length; i++ ) {
	$('#'+this.fields[i]+'s').empty();
    }
  
    $.ajax({

	url: "/finder/" + field + 's?spec=' + encodeURI(JSON.stringify(spec))

    }).done(function(list){


        var ul = $('#'+field+'s',that.window).empty();
	console.log(list);

        $.each(list,function(i) {

            var newspec = $.extend({},spec);
            newspec[field] = list[i];

	    var a = $('<a href="#">' + list[i] + '</a>');

	    a.click(function() {
                $('#'+field+'s>li>a').removeClass('finder-li-highlighted');
                $(this).addClass('finder-li-highlighted');
		that.get(index+1,newspec);
	    });

	    var li = $('<li></li>').append(a);
	    ul.append(li);

        });

    });

}

Finder.prototype.launch = function() {

    this.window.empty();
    this.window.html(this.template());
    this.get(0,{});
    this.window.modal('toggle');

}

Finder.prototype.template = function() {

  var html = ' \
    <div class="modal-header"> \
      <button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button> \
      <h3>Select '+this.kind+'</h3> \
    </div> \
    <div class="modal-body finder-body"> \
      <div class="row-fluid"> \
        \
        <div class="finder-column span2"> \
          <b>Projects</b> <div class="finder-list-container"><ul class="finder-list" id="projects"></ul></div> \
        </div> \
        \
        <div class="finder-column span2"> \
          <b>Types</b> <div class="finder-list-container"><ul class="finder-list" id="types"></ul></div> \
        </div> \
        \
        <div class="finder-column span3"> \
          <b>Samples</b> <div class="finder-list-container"><ul class="finder-list" id="samples"></ul></div> \
        </div>';

    if ( this.kind == "Items" ) {
  
      html += '  \
        <div class="finder-column span3"> \
          <b>Containers</b> <div class="finder-list-container"><ul class="finder-list" id="containers"></ul></div> \
        </div> \
        \
        <div class="finder-column span2"> \
          <b>Items</b> <div class="finder-list-container"><ul class="finder-list" id="items"></ul></div> \
        </div>';
    } 

    html += ' \
      </div> \
    </div> \
    <div class="modal-footer"> \
      <a href="#" class="btn btn-primary">Ok</a> \
    </div> \
  </div>';

    return html;

}