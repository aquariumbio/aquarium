function MetacolDrawing(places,transitions, marking,tag) {

  var that = this;
  
  // instance variables
  this.places = {};
  this.transitions = transitions;
  this.marking = marking;

  // enrich the places from a list of strings to a list of objects
  for ( i in places ) {
    this.add_place(places[i]);
  }

  // mark transitions as not visited
  for ( i in this.transitions ) {
    this.transitions[i].visited = false;
  }

  // parameters
  this.scale = 60;
  this.r = 20;
  this.da = 2*Math.PI/8;
  this.dist = 1.25;

  // drawing
  this.svg = d3.select('#'+tag).append("svg");

  // draw
  this.draw_place(places[0],1,1,0);

  var lineData = [ { "x": 1,   "y": 5},  { "x": 20,  "y": 20},
                   { "x": 40,  "y": 10} ]; 

  var line = d3.svg.line()
   .x(function(d) { return d.x; })
   .y(function(d) { return d.y; })
   .interpolate("basis");

  var lg = this.svg.append('path')
    .attr('d', line(lineData) )
    .attr('stroke', 'blue')
    .attr('stroke-width',2)
    .attr('fill','none');

}

MetacolDrawing.prototype.draw_place = function(name,x,y,theta) {

  if ( !this.places[name].visited ) {

    console.log('drawing ' + name );

    this.places[name].visited = true;
    this.places[name].x = x;
    this.places[name].y = y;
    this.places[name].theta = theta;

    this.svg.append("circle")
      .attr("cx", x*this.scale)
      .attr("cy", y*this.scale)
      .attr("r", this.r)
      .style("stroke", "black")
      .attr("fill","white");

    var T = this.postset(name);

    var a = theta;

    for ( var i in T ) {

      if ( !this.transitions[T[i]].visited ) {
        this.draw_transition(T[i],x+this.dist*Math.cos(a),y+this.dist*Math.sin(a),a);
        a += this.da;
      }
    }

  }

}

MetacolDrawing.prototype.draw_transition = function(t,x,y,theta) {

  if ( !this.transitions[t].visited ) {

    console.log('drawing ' + t );

    this.transitions[t].visited = true;
    this.transitions[t].x = x;
    this.transitions[t].y = y;
    this.transitions[t].theta = theta;

    var a = 360*theta/(2*Math.PI),
       rx =  x*this.scale-this.r/4,
       ry =  y*this.scale-this.r/4;

    this.svg.append('rect')
      .attr("transform","translate(" +rx+ "," +ry+ ") rotate(" +a+ ") " )
      .attr("width",this.r/2)
      .attr("height",this.r/2)
      .style("stroke", "black")
      .attr("fill","black");

    var a = theta;
    for ( var p in this.transitions[t].post ) {
      var name = this.transitions[t].post[p];
      if ( !this.places[name].visited ) {
        this.draw_place(name,x+this.dist*Math.cos(a),y+this.dist*Math.sin(a),a);
        a += this.da;
      }

    }

  }

}

MetacolDrawing.prototype.add_place = function(name) {
  this.places[name] = { name: name, visited: false };
}

MetacolDrawing.prototype.postset = function(p) {

  var T = [];
  for ( j in this.transitions ) {
    if ( $.inArray(p,this.transitions[j].pre) >= 0 ) {
      if ( $.inArray(j,T) == -1 ) {
        T.push(j); 
      }
    }
  }

  return T;
}

MetacolDrawing.prototype.draw = function() {

}
