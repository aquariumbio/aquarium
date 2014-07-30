
Krill.prototype.empty_table = function(r,c) {

  var table = $('<table></table>').addClass('krill-transfer-table');
  var matrix = [];

  for(var i=0;i<=r;i++) {
    var tr = $('<tr />');
    var row = [];
    for(var j=0; j<=c; j++) {
      if ( i==0 && j != 0 ) {
        td = $('<td>'+j+'</td>').addClass('index');
      } else if ( i != 0 && j == 0 ) {
        td = $('<td>'+i+'</td>').addClass('index');        
      } else if ( i == 0 && j == 0 ) {
        td = $('<td />').addClass('index');       
      } else {
        td = $('<td />');  
        row.push(td);
      }
      tr.append(td);      
    }
    if ( i>0 ) {
      matrix.push(row);
    }
    table.append(tr);
  }

  return { el: table, matrix: matrix };

}

Krill.prototype.transfer = function(x) {

  var that = this;

  var container  = $('<div></div>').addClass('krill-transfer-container');
  var from = $('<div />').addClass('krill-from-container');
  var to = $('<div />').addClass('krill-to-container');

  var from_table = this.empty_table(x.from.rows,x.from.cols);
  from_table.el.addClass('krill-transfer-from');

  var to_table   = this.empty_table(x.to.rows,x.to.cols);
  to_table.el.addClass('krill-transfer-to');

  var arrow      = $("<span><i class='icon-arrow-right' /></span>").addClass('krill-transfer-arrow');

  from.append($('<h3>'+x.from.id+': '+x.from.type+'</h3>'),from_table.el);
  to.append($('<h3>'+x.to.id+': '+x.to.type+'</h3>'),to_table.el);
  to.append(to_table);

  var info = $('<div />').addClass('krill-transfer-info');

  container.append(from,arrow,to,info);

  $.each(x.routing,function() {

    console.log(this);
    var route = this;

    var from = from_table.matrix[this.from[0]][this.from[1]];
    var from_name = x.from.type + ' ' + x.from.id;

    var to = to_table.matrix[this.to[0]][this.to[1]];
    var to_name = x.to.type + ' ' + x.to.id;

    from.addClass('krill-transfer-todo').click(function(){

      // clear the to table
      $.each(to_table.matrix,function(){
        $.each(this,function(){
          this.removeClass();
        });
      });

      from.removeClass();
      from.addClass('krill-transfer-doing');
      to.addClass('krill-transfer-todo');

      if ( route.volume ) {
        var q = route.volume + ' uL'
      } else {
        var q = "all"
      }

      info.empty().append('<p>Transfer '+q+' of '+route.sample_name+' from '+from_name+' location '+route.from+' to '+to_name+' location '+route.to+'.</p>');

      to.click(function(){
        from.removeClass();
        to.removeClass();
        from.addClass('krill-transfer-done');
        to.addClass('krill-transfer-done');
       });

    });

  });

  return container;

}

