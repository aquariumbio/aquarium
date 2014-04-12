function render_json(tag,obj) {

    if ( typeof obj == "number" || typeof obj == "string" ) {

        $(tag).append("<span class='json_const'>" + obj + "</span>");

    } else if ( obj.constructor.name == "Array" ) {

	var list = $( "<ul class='json_list'/>" );

        $.each(obj, function(i,v) {
            var li = $("<li />");
            render_json(li,v);
            list.append(li);      
        });

        $(tag).append(list);

    } else {

      	var list = $( "<ul class='json_hash'/>" );

        $.each(obj, function(k,v) {
            var li = $("<li />");
            li.append("<span class='json_key'>" + k + ": </span>");
            render_json(li,v);
            list.append(li);      
        });

        $(tag).append(list);

    }

}