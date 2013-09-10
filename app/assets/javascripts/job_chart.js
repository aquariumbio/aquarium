//
// Job Chart
// 
// Displays users (vertical axis) and job start and stop times (horizontal axis). 
// Used on the status page.
//

  function Row() {
    this.items = [];
  }
 
  HOUR = 60*60;

  function JobChart(id) {

    // The div into which to plot
    this.div = document.getElementById(id);

    // Row data: Has the form { rowname1: [ data11, data12, ... ], rowname2: [ data21, data22, ... ] }
    this.rows = new Object();

    // Figure out when is now
    this.compute_dates(); 

    // Cursor
    temp = this.now;
    temp.setHours(this.now.getHours() + 1);
    temp.setMinutes(0);
    temp.setSeconds(0);
    this.cursor = temp.getTime()/1000 + HOUR; // The right side of the viewer
  
    // Zoom
    this.zoom = 24; // number of hours in the vierwer
    this.min = this.cursor;
    this.last_update = this.cursor;
  
    var that = this;

    // Controls
    this.forward = document.getElementById('forward'); 
    this.forward.addEventListener ( 'click', function() {
      that.cursor += HOUR;
      that.render();
      that.get_jobchart_data();
    } );

    this.zoom_in = document.getElementById('zoom_in');
    this.zoom_in.addEventListener ( 'click', function() {
      if ( that.zoom > 24 ) {
	that.zoom -= 24;
      } else if ( that.zoom > 1 ) {
	that.zoom -= 1;
      } 
      that.render();
      that.get_jobchart_data();
    } );

    this.back = document.getElementById('back');
    this.back.addEventListener ( 'click', function() {
      that.cursor -= HOUR;
      that.render();
      that.get_jobchart_data();
    } );

    this.zoom_out = document.getElementById('zoom_out');
    this.zoom_out.addEventListener ( 'click', function() {
      if ( that.zoom < 24 ) {
        that.zoom += 1;
      } else {
        that.zoom += 24;
      }
      that.render();
      that.get_jobchart_data();
    } );

    // Get latest data
    this.get_jobchart_data();

  }

  JobChart.prototype.update = function() {

    this.compute_dates(); 
    this.update_current_time();

    // Get latest data
    this.get_jobchart_data();

  }

  JobChart.prototype.add_item = function(rowname,item) {

    if ( !this.rows[rowname] ) {
      this.rows[rowname] = new Row();
    }

    this.rows[rowname].items.push(item);
    this.num_rows = Object.keys(this.rows).length;

  }

  JobChart.prototype.get_jobchart_data = function() {

    this.compute_dates();
    var newmin = Math.min ( this.min, this.cursor - this.zoom*HOUR );

    var that = this;
    var xmlhttp = new XMLHttpRequest();
    var url = "jobchart.json"
            + "?oldmin=" + Math.floor(this.min) 
            + "&newmin=" + Math.floor(newmin) 
            + "&max=" + Math.floor(this.last_update);

    this.last_update = this.now.getTime() / 1000;

    xmlhttp.onreadystatechange = function() {

       if ( this.readyState==4 && this.status==200 ) {

         var plain = xmlhttp.responseText;
         var data = JSON.parse ( plain );
         var update = false;

         for ( var user in data ) {

           update = true;

           for ( var i=0; i<data[user].length; i++ ) {
             that.add_item ( user, data[user][i] );
  	   }

         }

         if ( update ) {
           that.render();
         }

       }

    }

    xmlhttp.open("POST",url);
    xmlhttp.setRequestHeader("Content-Type","application/x-www-form-urlencoded");
    xmlhttp.send();

    this.min = newmin;

  }

  JobChart.prototype.compute_sizes = function() {

    this.x_offset = 120;
    this.y_offset = 10;
    this.width = this.div.offsetWidth - this.x_offset - 10;
    this.height = this.div.offsetHeight - this.y_offset - 30;
    this.num_rows = Math.max ( 5, Object.keys(this.rows).length );
    this.div.style.height = ( 20*(2.5+this.num_rows) + 2*this.y_offset ) + 'px';

  }

  JobChart.prototype.render_background = function() {

    this.compute_dates();

    for ( var i=this.zoom; i>0; i-- ) {

      var d = new Date ( ( this.cursor - i*HOUR )*1000  );
   
      // Draw a bar for each hour or group of hours
      var b = this.bar   ( this.cursor - i*HOUR, 0,             HOUR, this.num_rows, i%2==0 ? "#eff" : "#fff" );
      if ( this.zoom <= 24 || ( this.zoom <= 72 && d.getHours() % 4 == 0 ) 
                           || ( this.zoom <= 192 && d.getHours() % 12 == 0 )
                           || ( this.zoom > 192 && d.getHours() %24 == 0 ) ) {
        var t = this.text  ( this.cursor - i*HOUR, this.num_rows, HOUR, 1, d.getHours() + ":00" );
        t.style.fontSize = '9pt';
        t.style.textAlign = 'left';
      }

      // Print the date
      if ( d.getHours() == 0 ) {
        this.bar ( this.cursor - i*HOUR, 0, 1, this.num_rows+3, '#aaa' );
        var c = this.text  ( this.cursor - i*HOUR, this.num_rows+1, HOUR, 1, d.toDateString() );
        c.style.fontSize = '9pt';
        c.style.textAlign = 'left';
        c.style.fontWeight = 'bold';
        c.style.whiteSpace = 'nowrap';
      }

    }

  }

  JobChart.prototype.render_current_time = function() {

    this.current_time_pointer = this.bar ( this.now.getTime()/1000,0,1,this.num_rows, "#f00" );

    this.current_time_text = this.text ( 
         this.now.getTime()/1000, 0, HOUR, this.num_rows, 
        '&nbsp;&nbsp;' + this.now.toTimeString().replace(/.*(\d{2}:\d{2}:\d{2}).*/, "$1") );

    this.current_time_text.style.color = '#f00';
    this.current_time_text.style.fontSize = '16pt';
    this.current_time_text.style.padding = 0;
    this.current_time_text.style.textAlign = 'left';

  }

  JobChart.prototype.update_current_time = function() {

    (this.current_time_pointer).parentNode.removeChild(this.current_time_pointer);
    (this.current_time_text).parentNode.removeChild(this.current_time_text);
    this.render_current_time();

  }

  JobChart.prototype.render_rows = function() {

    var i = 0;

    for ( var login in this.rows ) {

      var t = this.text ( 0, i*20 + this.y_offset, this.x_offset, 20, login + '&nbsp;', false );
      t.style.textAlign = 'right';
      t.style.fontSize = '12pt';
      t.style.padding = 0;

      var items = this.rows[login].items;

        for ( var j=0; j<items.length; j++ ) {

          var x = this.x_offset + (this.days-this.min-2) * this.width / this.days + p*this.width/this.days;
          var y = 20*i + this.y_offset;
          var w = Math.max ( (q-p)*this.width/this.days, 10.0 );
          var h = 20;

          this.bar(items[j].start,i,items[j].stop-items[j].start,1,"#234");

      }

      i += 1;

    }

  }

  JobChart.prototype.render = function() {
    while ( this.div.hasChildNodes()) {
      this.div.removeChild(this.div.lastChild);
    }  
    this.compute_sizes();
    this.render_background();
    this.render_current_time();
    this.render_rows();
    
  }

  JobChart.prototype.compute_dates = function () {

    this.now  = new Date();

  }

  JobChart.prototype.new_div = function(x,y,w,h,classname,scale) {

  if ( typeof scale === 'undefined' ) {

      // x and w are in minutes and need to be scaled and translated
      // to fit the viewer
      var X = this.width * ( 1 + ( x - this.cursor ) / ( this.zoom * HOUR ) ) + this.x_offset;
      var W = Math.max(2,this.width * w / ( this.zoom * HOUR ));

      // y and h are in number of rows
      var Y = this.y_offset + 20*y;
      var H = 20*h;

    } else {

      var X=x;
      var W=w;
      var Y=y;
      var H=h;

    }

    var b = document.createElement ( 'div' );
    b.className = classname;
    b.style.left = X + 'px'; 
    b.style.top = Y + 'px';
    b.style.width = Math.max(1,W) + 'px';
    b.style.height = H + 'px';
    return b;

  }

  JobChart.prototype.bar = function(x,y,w,h,col) {

    var b = this.new_div(x,y,w,h,'bar');
    b.style.background = col;
    this.div.appendChild(b);
    return b;

  }

  JobChart.prototype.text = function(x,y,w,h,str,scale) {

  var b = this.new_div(x,y,w,h,'text',scale);
    b.innerHTML = str;
    this.div.appendChild(b);
    return b;

  }

