function Finder(kind,callback) { 

    var that = this;
    this.type = "";
    this.kind = kind;
    this.callback = callback;
    this.selections = [];
    this.selection_names = [];

    if ( kind == 'Samples' ) {

        this.fields = [ "project", "type", "sample" ]; 
        this.select_method = this.select_sample;

    } else if ( kind == "Items" ) { 

        this.fields = [ "project", "type", "sample", "container", "item" ];
        this.select_method = this.select_item;

    } else { // kind is either a sample type or item type

        $.ajax({
            url: "/finder/type?type=" + encodeURI(kind)
        }).done(function(result) {
            that.type = that.kind;   // e.g. Plasmid or Primer Aliquot
            that.kind = result.type; // e.g. Samples or Items
            if ( result.type == 'Samples' ) {
                that.fields = [ "project", "type", "sample" ];
                that.select_method = that.select_sample;
            } else {
                that.fields = [ "project", "type", "sample", "container", "item" ];
                that.select_method = that.select_item;
            }
            
        });

    }

    this.launch_button = $('<button type="button">'+kind+'</button>')
      .addClass('btn btn-small finder-btn')
	  .click(function(){that.launch();});

    this.window = $('<div></div>').addClass('modal fade finder').css('display','none');
    $(document.body).append(this.window);

    return this.launch_button;

}

Finder.prototype.select = function(field,x) {

    var y;
    var that = this;

    if ( field == 'item' ) {
    	y = x.item;
    } else {
	   y = x.sample_id;
    }

    var i = $.inArray(y,this.selections);

    if ( i >= 0 ) {
        this.selections.splice(i,1);
        if ( this.kind == "Samples" ) {
            this.selection_names.splice(i,1);
        }
        $('#'+field+'-'+y,this.window).parent().removeClass('finder-selected');
    } else {
        this.selections.push(y);
        if ( this.kind == "Samples" ) {
            this.selection_names.push(x.sample_name);
        }
        $('#'+field+'-'+y,this.window).parent().addClass('finder-selected');
    }

    if ( field == 'sample' ) {
        $.ajax({
	    url: "/finder/sample_info?spec=" + encodeURI(JSON.stringify(x))
	}).done(function(info) {
        render_json($('#sample-info',that.window).empty(),info);
        console.log('rendered json');
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

	   url: "/finder/" + field + 's?spec=' + encodeURI(JSON.stringify(spec)) + "&filter=" + encodeURI(this.type)

    }).done(function(list){

        var ul = $('#'+field+'s',that.window).empty();

        $.each(list,function(i) {

            var li = $('<li></li>');
            var newspec = $.extend({},spec);
            newspec[field] = list[i].name;
            if ( field == 'sample' ) {
                newspec["sample_id"] = list[i].id;
                newspec["sample_name"] = list[i].name;
            }

    	    var a = $('<a href="#" id='+field+'-'+list[i].id+'>' + list[i].name + '</a>');

            // highlight selected items
            if ( field == 'item' && $.inArray(list[i].id,that.selections) >=0 ) {
                li.addClass('finder-selected');
    	    } else if ( that.kind == "Samples" && field == 'sample' && $.inArray(list[i].id,that.selections) >=0 ) {
                li.addClass('finder-selected');
    	    }
            
            li.click(function() {

                if ( index < that.fields.length-1 ) {
                    $('#'+field+'s>li').removeClass('finder-li-highlighted');
                    $(this).addClass('finder-li-highlighted');
                    that.get(index+1,newspec);
                } else {
        		    that.select(field,newspec);
        		}

            });

            li.append(a);
    	    ul.append(li);

        });

    });

}

Finder.prototype.launch = function() {

    var that = this;

    this.selections = [];
    this.selection_names = [];

    this.window.empty();
    this.window.html(this.template());
    this.get(0,{});
    this.window.modal('toggle');

    $('#ok',this.window).click(function() {
       that.window.modal('toggle');
	   that.callback(that.selections,that.selection_names);
       console.log("Launch 3");
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
          <h1>Projects</h1> <div class="finder-list-container"><ul class="finder-list" id="projects"></ul></div> \
        </div> \
        \
        <div class="finder-column span2"> \
          <h1>Types</h1> <div class="finder-list-container"><ul class="finder-list" id="types"></ul></div> \
        </div> \
        \
        <div class="finder-column span3"> \
          <h1>Samples</h1> <div class="finder-list-container"><ul class="finder-list" id="samples"></ul></div> \
        </div>';

    if ( this.kind == "Items" ) {
  
      html += '  \
        <div class="finder-column span3"> \
          <h1>Containers</h1> <div class="finder-list-container"><ul class="finder-list" id="containers"></ul></div> \
        </div> \
        \
        <div class="finder-column span2"> \
          <h1>Items</h1> <div class="finder-list-container"><ul class="finder-list" id="items"></ul></div> \
        </div>';
    } else {
      html += '<div class="finder-column span5"><h1>Sample Information</h1><div id="sample-info"></div></div>'
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