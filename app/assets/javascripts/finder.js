function Finder(kind,callback) {

    var that = this;
    this.type = "";
    this.kind = kind;
    this.callback = callback;
    this.selections = [];

    if ( kind == 'Samples' ) {

        this.fields = [ "project", "type", "sample" ];
        this.select_method = this.select_sample;

    } else if ( kind == "Items" ) { 

        this.fields = [ "project", "type", "sample", "container", "item" ];
        this.select_method = this.select_item;

    } else { // kind is either a sample type or item type

        $.ajax({
            url: "/finder/type?type=" + kind
        }).done(function(result) {
            that.type = that.kind;   // e.g. Plasmid or Primer Aliquot
            that.kind = result.type; // e.g. Plasmids or Items
            if ( result.type == 'Samples' ) {
                that.fields = [ "project", "type", "sample" ];
                that.select_method = that.select_sample;
            } else {
                that.fields = [ "project", "type", "sample", "container", "item" ];
                that.select_method = that.select_item;
            }
        });

    }

    this.launch_button = $('<button>'+kind+'</button>')
      .addClass('btn btn-small finder-btn')
	  .click(function(){that.launch();});

    this.window = $('<div></div>').addClass('modal hide fade finder');
    $(document.body).append(this.window);

    return this.launch_button;

}

Finder.prototype.select = function(field,x) {

    var y;

    if ( field == 'item' ) {
    	y = x.item;
    } else {
	   y = x.sample_id;
    }

    var i = $.inArray(y,this.selections);

    if ( i >= 0 ) {
        this.selections.splice(i,1);
        $('#'+field+'-'+y).removeClass('finder-selected');
    } else {
        this.selections.push(y);
        $('#'+field+'-'+y).addClass('finder-selected');
    }

    if ( field == 'sample' ) {
        $.ajax({
	    url: "/finder/sample_info?spec=" + encodeURI(JSON.stringify(x))
	}).done(function(info) {
        render_json($('#sample-info').empty(),info);
	});
    }

}

Finder.prototype.get = function(index,spec) {

    var that = this;
    var field = this.fields[index];

    // clear this and higher fields 
    for ( var i=index; i<=this.fields.length; i++ ) {
	   $('#'+this.fields[i]+'s').empty();
    }
  
    $.ajax({

	   url: "/finder/" + field + 's?spec=' + encodeURI(JSON.stringify(spec)) + "&filter=" + this.type

    }).done(function(list){

        var ul = $('#'+field+'s',that.window).empty();

        $.each(list,function(i) {

            var newspec = $.extend({},spec);
            newspec[field] = list[i].name;
            if ( field == 'sample' ) {
                newspec["sample_id"] = list[i].id;
            }

    	    var a = $('<a href="#" id='+field+'-'+list[i].id+'>' + list[i].name + '</a>');

            // highlight selected items
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
        		    that.select(field,newspec);
        		}

            });

            var li = $('<li></li>').append(a);
    	    ul.append(li);

        });

    });

}

Finder.prototype.launch = function() {

    var that = this;

    this.selections = [];
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
      <h3>Select '+this.kind+' of type '+this.type+'</h3> \
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
    } else {
      html += '<div class="finder-column span5"><b>Sample Information</b><div id="sample-info">-</div></div>'
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