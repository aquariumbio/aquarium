function Workflow(id) {

  this.id = id;
  var that = this;
  this.last_key = 0;

  var $injector = angular.injector(['ng']);
  this.q = $injector.get('$q')

}

Workflow.prototype.get = function() {

  var deferred = this.q.defer();
  var that = this;

  $.ajax({

    url: "/workflows/"+that.id+".json"

  }).done(function(data) {

    that.specification = data.specification;
    that.name = data.name;    
    deferred.resolve(that);
    
  }).fail(function(data) {

    deferred.reject(that);

  });

  return deferred.promise;

}

Workflow.prototype.operations = function() {
  return this.specification.operations;
}

Workflow.prototype.io = function() {
  return this.specification.io;
}

Workflow.prototype.description = function() {
  return this.specification.description;
}

Workflow.prototype.graph = function() {

  var graph = this;

  var g = { 
    class: "go.GraphLinksModel",
    linkFromPortIdProperty: "fromPort",
    linkToPortIdProperty: "toPort",
    nodeDataArray: [],
    linkDataArray: []
  };

  $.each(this.operations(),function() {

    var that = this;

    var op = $.extend({},this,{
      key: this.id,
      name: this.name,
      category: "operation",
      inputPorts: [],
      outputPorts: [],
      dataPorts: [],
      exceptionPorts: []
    });

    graph.link(op,g,this.inputs,    "input", "green","inventory","io", "from");
    graph.link(op,g,this.outputs,   "output","pink","inventory","io", "to");
    graph.link(op,g,this.parameters,"data", "blue", "inventory","data","from");
    graph.link(op,g,this.data,      "data", "cyan", "inventory","data","to");

    $.each(this.exceptions,function() {

      var exp = $.extend({},this,{
        key: that.id + "_" + this.name,
        name: this.name,
        category: "exception",
        inputPorts: [ { portId: "input", portColor: "orange" }],
        dataPorts: [],
        outputPorts: []
      });

      g.nodeDataArray.push(exp);

      op.exceptionPorts.push({
        portId: this.name,
        portColor: "orange"
      });

      g.linkDataArray.push({
        to: that.id + "_" + this.name,
        from: op.key,
        fromPort: this.name,
        toPort: "input",
        category: "io"
      });

      graph.link(exp,g,this.outputs, "output","pink","inventory","io", "to");      
      graph.link(exp,g,this.data, "data","cyan","inventory","data", "to");         

    });

    g.nodeDataArray.push(op);

  });

  $.each(this.io(),function() {

    g.linkDataArray.push({
      from: this.from[0] + "_" + this.from[1],
      to: this.to[0] + "_" + this.to[1],
      category: "identification"
    });

  });

  return go.Model.fromJson(g);  

}

Workflow.prototype.link = function(op,g,parts,name,color,nodeType,linkType,dir) {

  var lc = "light" + color.toLowerCase().replace(/\b[a-z]/g, function(letter) {
    return letter.toUpperCase();
  });

  $.each(parts,function() { 

    op[name+"Ports"].push({
      portId: this.name,
      portColor: color
    });

    g.nodeDataArray.push($.extend({},this,{
      key: op.key + "_" + this.name,
      name: this.name,
      category: nodeType,
      color: lc,
      type: name
    }));

    if ( dir == "from" ) {

      g.linkDataArray.push({
        to: op.key,
        from: op.key + "_" + this.name,
        toPort: this.name,
        category: linkType
      });      

    } else {

      g.linkDataArray.push({
        from: op.key,
        to: op.key + "_" + this.name,
        fromPort: this.name,
        category: linkType
      });   

    }

  }); 

}
