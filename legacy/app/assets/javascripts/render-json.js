function render_json(tag,obj,type_info,id_type) {

    var that = this;
    var show_types = type_info ? true : false;

    if ( obj == null ) {

        $(tag).append("<span class='json_const'>null</span>");

    } else if ( typeof obj == "number" || typeof obj == "string" || typeof obj == "boolean" ) {

        if ( id_type ) {
            $(tag).append(json_get_id_info(obj,id_type));
        } else if ( typeof obj == "boolean" ) {
            $(tag).append("<span class='json_const'>" + (obj ? 'true' : 'false') + "</span>");
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

	   } else {
          $(tag).append("<span>[]</span>");
       }

    } else {

      	var list = $( "<ul class='json_hash'/>" );
        var empty = true;

        $.each(obj, function(k,v) {
            empty = false;
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

        if (empty) {
            list.append("<li>&nbsp;</li>");
        }

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

