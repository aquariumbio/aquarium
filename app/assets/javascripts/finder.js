function Finder(kind,callback) {

    var that = this;
    this.kind = kind;
    this.callback = callback;
    this.selections = [];

    if ( kind == 'Samples' ) {

        this.fields = [ "project", "type", "sample" ];
        this.select_method = this.select_sample;

    } else { // assume kind == 'Items'

        this.fields = [ "project", "type", "sample", "container", "item" ];
        this.select_method = this.select_item;

    } 

    this.launch_button = $('<button>'+kind+'</button>')
      .addClass('btn btn-small finder-btn')
	.click(function(){that.launch();});

    this.window = $('<div></div>').addClass('modal hide fade finder');
    $(document.body).append(this.window);

    return this.launch_button;

}

Finder.prototype.select_sample = function(x) {

    var i = $.inArray(x.sample_id,this.selections);

    if ( i >= 0 ) {
        this.selections.splice(i,1);
        $('#sample-'+x.sample_id).removeClass('finder-selected');
    } else {
        this.selections.push(x.sample_id);
        $('#sample-'+x.sample_id).addClass('finder-selected');
    }

    console.log("Sample " + JSON.stringify(this.selections));

}

Finder.prototype.select_item = function(x) {

    var i = $.inArray(x.item,this.selections);

    if ( i >= 0 ) {
        this.selections.splice(i,1);
        $('#item-'+x.item).removeClass('finder-selected');
    } else {
        this.selections.push(x.item);
        $('#item-'+x.item).addClass('finder-selected');
    }

    console.log("Item " + JSON.stringify(this.selections));

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
            newspec[field] = list[i].name;
	    if ( field == 'sample' ) {
		newspec["sample_id"] = list[i].id;
	    }
	    var a = $('<a href="#" id='+field+'-'+list[i].id+'>' + list[i].name + '</a>');

            // highlight selected items
	    console.log ( field + ', ' + list[i].id + ', [' + that.selections + ']' );
            if ( field == 'item' && $.inArray(list[i].id,that.selections) >=0 ) {
		a.addClass('finder-selected');
	    } else if ( that.kind == "Samples" && field == 'sample' && $.inArray(list[i].id,that.selections) >=0 ) {
		a.addClass('finder-selected');
	    }
            
	    a.click(function() {

                if ( index < that.fields.length-1 ) {
                    $('#'+field+'s>li>a').removeClass('finder-li-highlighted');
                    $(this).addClass('finder-li-highlighted');
	            that.get(index+1,newspec);
		} else {
		    that.select_method(newspec);
		}

	    });

	    var li = $('<li></li>').append(a);
	    ul.append(li);

        });

    });

}

Finder.prototype.launch = function() {

    var that = this;

    this.window.empty();
    this.window.html(this.template());
    this.get(0,{});
    this.window.modal('toggle');

    $('#ok',this.window).click(function() {
        that.window.modal('toggle');
	that.callback(that.selections);
    });

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
      <a href="#" id="ok" class="btn btn-primary">Ok</a> \
    </div> \
  </div>';

    return html;

}