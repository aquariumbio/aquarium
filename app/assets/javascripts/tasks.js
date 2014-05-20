function render_json(tag,obj) {

    if ( typeof obj == "number" || typeof obj == "string" ) {

        $(tag).append("<span class='json_const'>" + obj + "</span>");

    } else if ( obj.constructor.name == "Array" ) {

        if ( obj.length > 0 ) {

	    var list = $( "<ul class='json_list'/>" );

	    $.each(obj, function(i,v) {
		var li = $("<li />");
		render_json(li,v);
		list.append(li);      
	    });

	    $(tag).append(list);

	}

    } else {

      	var list = $( "<ul class='json_hash'/>" );

        $.each(obj, function(k,v) {
            var li = $("<li />");
            li.append("<span class='json_key_inline'>" + k + ": </span>");
            render_json(li,v);
            list.append(li);      
        });

        $(tag).append(list);

    }

}

function render_json_editor(tag,obj,proto) {

    if ( typeof obj == "string" ) {

        var i = $("<textarea class='json_edit_string'>" + obj + "</textarea>");
        $(tag).append(i);

    } else if ( typeof obj == "number" ) {

        var i = $("<input type='number' class='json_edit_number' value=" + obj + "></input>");
        $(tag).append(i);

    } else if ( obj.constructor.name == "Array" ) {

         var list = $( "<ul class='json_editor_array'/>" );

         $.each(obj, function(i,v) {
	   var li = $("<li />");
           render_json_editor(li,v,proto[proto.length-1]);
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
               render_json_editor(li,proto[proto.length-1],proto[proto.length-1]);
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
            li.append("<span class='json_key'>" + k + "</span>");
            render_json_editor(li,v,proto[k]);
            list.append(li);
        });

        $(tag).append(list);

    }

}

function json_editor_extract(tag) {

    return editor_extract_aux(tag.children().first());

}

function editor_extract_aux(tag) {

    console.log(tag);

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

    } else {

        x = {};
        tag.children().each(function(i,v){
            var key = $(v).children().first();
            var val = $(v).children().eq(1);
            x[key.html()] = editor_extract_aux($(val));
        });

    }

    console.log(x);

    return x;

}
