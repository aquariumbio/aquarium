
function ArgumentUI(args,cart,objects) {

    this.cart = cart;
    this.objects = objects;

    for ( var i in args ) {

        var label = this.label(args[i]);
        var type = args[i]; // Note: parser should return number, string, sample, objecttype 
                            // or base_array where base is number, string, or sample

        var form = this[args[i].type](args[i]);

        var well = $('<div></div>');
        well.addClass('argument');
        well.append(label,form);

        $('#argument-chooser').append(well);

    }

    $('#button-area').append(
	$('<button>Scheule New Job</button>')
            .addClass('btn btn-primary')
    );

}

ArgumentUI.prototype.label = function(arg) {

    return $('<div />').append($('<label />').html( '<b>' + arg.name + "</b>: " + arg.description));

}

ArgumentUI.prototype.number = function(arg) {

    x = $('<input />');
    x[0].type = 'number';
    x[0].step = 'any';
    return x;

}

ArgumentUI.prototype.string = function(arg) {

    x = $('<input />');
    x[0].type = 'text';
    return x;

}

ArgumentUI.prototype.sample = function(arg) {

    x = $('<select />');
    
    for ( var i in this.cart ) {
	x.append('<option>' + this.cart[i].id + ': ' + this.cart[i].sample_name + '</option>' );
    }

    return x;

}

ArgumentUI.prototype.objecttype = function(arg) {

    var x = $('<div class="object-menu" />');
    var choice = $('<div class="choice"/>');
    choice.append('<p>1 L Bottle</p>');
    x.append(choice);    

    var top = $('<ul />');
    var title = $('<a href="#">Choose Object</a>' );
    var top_li = $('<li />');
    var handlers = $('<ul />');


    for ( var handler in this.objects ) {
	var h = $('<li />');

        h.append('<a href="#">' + handler + '</a>' );
        handlers.append(h);
        var objects = $('<ul />');
        for ( var i in this.objects[handler] ) {
            var name =  this.objects[handler][i]
            var ob = $('<li />');
            ob.append('<a href="#">' + name + "</a>");
            (function(x){
              ob.click(function(e) {
  		choice.html('<p>' + x + '</p>');
              });
            }(name));
            objects.append(ob);
	}
        h.append(objects);
    }

    top_li.append(title)
    top_li.append(handlers)
    top.append(top_li);
    top.menu();

    x.append(top);
    x.css('z-index',10);

    return x;

}

ArgumentUI.prototype.number_array = function(arg) {
    return this.array(arg,'number');
}

ArgumentUI.prototype.string_array = function(arg) {
    return this.array(arg,'string');
}

ArgumentUI.prototype.sample_array = function(arg) {
    return this.array(arg,'sample');
}

ArgumentUI.prototype.array = function(arg,base) {
  
    var that = this;
   
    var l = $('<ol start="0" />');
    var li = $('<li />');
    li.append(this[base](arg));
    l.append(li);

    var more = $('<button>+</button>');
    more.addClass('btn btn-small sep');

    more.click(function(e){
        var li = $('<li />');
	li.append(that[base](arg))
        l.append(li);
    });

    var less = $('<button>-</button>');
    less.addClass('btn btn-small sep');

    less.click(function(e){
	l.find('li:last').remove();
    });

    var x = $('<div />');
    x.append(l,more,less);

    return x;

}