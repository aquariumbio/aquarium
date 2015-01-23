function render_json(tag,obj,type_info,id_type) {

    var that = this;
    var show_types = type_info ? true : false;

    if ( obj == null ) {

    } else if ( typeof obj == "number" || typeof obj == "string" || typeof obj == "boolean" ) {

        if ( id_type ) {
            $(tag).append(json_get_id_info(obj,id_type));
        } else {
            $(tag).append("<span class='json_const'>" + obj + "</span>");
        }

    } else if ( obj.constructor.name == "Array" ) {

        if ( obj.length > 0 ) {

    	    var list = $( "<ul class='json_list'/>" );

    	    $.each(obj, function(i,v) {
    		var li = $("<li />");
    		render_json(li,v,show_types,id_type);
    		list.append(li);      
    	    });

    	    $(tag).append(list);

	   }

    } else {

      	var list = $( "<ul class='json_hash'/>" );

        $.each(obj, function(k,v) {
            var li = $("<li />");
            if ( show_types ) {
                var key = that.json_editor_key(k);
                var type = that.json_editor_type(k);
                li.append("<span class='json_key_inline'>" + key + " <span class='json-sample-type'>(" + type + ")</span>: </span>");
            } else {
                li.append("<span class='json_key_inline'>" + k + ": </span>");
            }
            render_json(li,v,show_types,type);
            list.append(li);      
        });

        $(tag).append(list);

    }

}

function json_get_id_info(id,type) {

    var el = $("<span>"+id+"</span>").addClass('json-rich-id');

    $.ajax({
      url: encodeURI("/rich_id?id="+id+"&type="+type),
      dataType: "json",
    }).done(function(result) {
        console.log(result.error);
      if ( ! result.error ) {
        el.empty().append(json_rich_id_element(result));
      } else {
        el.empty().append('<span>'+result.error+"</span>");
      }
    });

    return el;

}

function json_rich_id_element(p) {

    var el;

    if ( p.item_id ) {
        if ( p.sample_id ) {
          el = $("<span><a href='/items/"+p.item_id+"'>"+p.item_id+"</a>"
            + " (<a href='/samples/"+p.sample_id+"'>"+ p.sample_name+"</a>) at "
            + p.location +"</span>");
        } else {
          el = $("<a href='/items/"+p.item_id+"'>"+p.item_id+"</a>");           
        }
    } else {
        el = $("<a href='/samples/"+p.sample_id+"'>"+p.sample_id+": "+ p.sample_name+"</a>");
    }

    return el;

}

function render_json_editor(tag,obj,proto,type,parent_list) {             

    if ( typeof obj == "string" ) {

        var i = $("<textarea class='json_edit_string'>" + obj + "</textarea>");
        $(tag).append(i);

    } else if ( !obj || typeof obj == "number" ) {

        var i = $("<input type='number' class='json_edit_number' value=" + obj + "></input>");

        $(tag).append(i);

        if ( arguments.length == 5 ) { var parlist = parent_list; }

        if ( arguments.length >= 4 && type != "" ) { // type provided

            $(tag).append(new Finder(type,function(selections) {
                /* put result in input tag */ 
                for ( var n=0; n<selections.length; n++ ) {
                    if ( n==0 ) { 
                       i.val(selections[n]);
                   } else {
                        if ( parlist ) { // parent is a list
                            var li = $('<li></li>');
                            render_json_editor(li,selections[n],proto[proto.length-1],type,list);
                            parlist.append(li);
                        }
                   }
                }
            }));
        }

    } else if ( obj.constructor.name == "Array" ) {

        var list = $( "<ul class='json_editor_array'/>" );

        $.each(obj, function(i,v) {
            var li = $("<li />");
            render_json_editor(li,v,proto[proto.length-1],type,list);
            list.append(li);      
    	});

        $(tag).append(list);

        var more = $('<button>+</button>');
        var less = $('<button>-</button>');

        $(tag).append(more,less);

        more.addClass('btn btn-small add-json-btn');

        more.click(function(e){

            var li = $('<li />');

            if ( proto.length > 0 ) {
                render_json_editor(li,proto[proto.length-1],proto[proto.length-1],type,list);
            } else {
                render_json_editor(li,"","");
            }

            list.append(li);

        });

        less.addClass('btn btn-small add-json-btn');
        less.click(function(e){
            list.children().last().remove();
        });

    } else {

      	var list = $( "<ul class='json_editor_hash'/>" );

        $.each(obj, function(k,v) {
            var li = $("<li />");
            li.append("<span class='json_key' data-key='"+k+"'>" + k.split(' ')[0] + "</span>");
            render_json_editor(li,v,proto[k],json_editor_type_from_proto(k,proto));
            list.append(li);
        });

        $(tag).append(list);

    }

}

function json_editor_key(str) {
    return parts = str.split(' ')[0];
}

function json_editor_type(str) {
    return parts = str.split(' ').slice(1,40).join(' ');
}

function json_editor_type_from_proto(str,proto) {

  var key = str.split(' ')[0];
  var temp = proto;

  for ( var k in proto ) {
    var parts = k.split(' ');
    if ( parts.length > 1 ) { // only include keys with type information
      temp[parts[0]] = json_editor_type(k);
    }
  }

  return temp[key];
}


function json_editor_extract(tag) {

    return editor_extract_aux(tag.children().first());

}

function editor_extract_aux(tag) {

    var x;

    if ( tag.attr('class') == 'json_edit_number' ) {

	var s = tag.val();

        if ( parseInt(s) == parseFloat(s) ) {
            x = parseInt(s);
        } else {
            x = parseFloat(s);
	}

    } else if ( tag.attr('class') == 'json_edit_string' ) {

	x = tag.val();

    } else if ( tag.attr('class') == 'json_editor_array' ) {

        x = [];
        tag.children().each(function(i,v){
            x.push(editor_extract_aux($($(v).children().first())));
        });

    } else { // hash

        x = {};
        tag.children().each(function(i,v){
            // var key = $(v).children().first();
            var key = $(v).children().first().data().key;
            var val = $(v).children().eq(1);
            x[key] = editor_extract_aux($(val));
        });

    }

    return x;

}
