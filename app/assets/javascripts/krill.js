function Krill(state,tag_name) {

    this.tag = $('#' + tag_name);

    this.state = state;

    i = this.state.length-1;
    while(this.state[i].operation != 'display' && i>0) {
	i--;
    }

    if(i>0) {
        this.current = this.state[i].content;
    } else {
	this.current = { note: "Nothing to display. Try reloading." }
    }
 
}

Krill.prototype.display = function(tag_name) {

    var ul = $('<ul></ul').addClass('krill-display-list');

    for(var i=0; i<this.current.length; i++) {

        var key = Object.keys(this.current[i])[0];
	ul.append(this[key](this.current[i][key]));

    }

    this.tag.append(ul);

}

Krill.prototype.title = function(x) {
    return $('<li>'+x+'</li>').addClass('krill-title');
}

Krill.prototype.note = function(x) {
    return $('<li>'+x+'</li>').addClass('krill-note');
}

Krill.prototype.check = function(x) {
    var check = $('<input type="checkbox"></input>').addClass('krill-checkbox');
    var span = $('<span>'+x+'</span>');
    return $('<li></li>').append(check).append(span).addClass('krill-check');
}

Krill.prototype.warning = function(x) {
    return $('<li>warning</li>');
}

Krill.prototype.select = function(x) {
    return $('<li>select</li>');
}

Krill.prototype.input = function(x) {
    return $('<li>input</li>');
}