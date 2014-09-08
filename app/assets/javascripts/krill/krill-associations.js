Krill.prototype.inventory = function() {

    var that = this;

    $.ajax({

        url: 'inventory?job=' + that.job,

    }).done(function(data){

        var ul = $('<ul></ul>').addClass('krill-inventory-list');
        for ( var i in data.takes ) {
            ul.append(that.item_li(data.takes[i]));
        }

      that.inventory_tag.empty().append($('<h4>In Use</h4>').addClass('krill-inventory-h4')).append(ul);

        if ( data.takes.length == 0 ) {
            that.inventory_tag.append("<p>None</p>").addClass('krill-inventory-none');
        }

        var ul = $('<ul></ul>').addClass('krill-inventory-list');

        for ( var i in data.touches ) {
            ul.append(that.item_li(data.touches[i]));
        }

        that.inventory_tag.append($('<h4>Used</h4>').addClass('krill-inventory-h4')).append(ul);

        if ( data.touches.length == 0 ) {
            that.inventory_tag.append("<p>None</p>").addClass('krill-inventory-none');
        }

    });

}

Krill.prototype.uploads = function() {

    var that = this;

    $.ajax({

        url: 'uploads?job=' + that.job,

    }).done(function(data){


        var ul = $('<ul></ul>').addClass('krill-associations-upload-list');

        for ( var i in data.uploads ) {
            ul.append(
                $('<li><a href="'+data.uploads[i].url+'"">' + data.uploads[i].name + '</a><span> (' + data.uploads[i].id + ')</span></li>')
            )
        }

        that.uploads_tag.append(ul);

    });

}