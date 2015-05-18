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

  this.workflow = $.ajax({

    url: "/workflows/"+that.id+".json"

  }).done(function(data) {

    that.workflow = data.specification;
    that.workflow_name = data.name;    
    deferred.resolve(that);
    
  }).fail(function(data) {

    deferred.reject(that);

  });

  return deferred.promise;

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

  $.each(this.workflow.operations,function() {

    var that = this;

    var op = {
      key: this.id,
      name: this.name,
      data: this,
      category: "operation",
      inputPorts: [],
      outputPorts: [],
      paramPorts: [],
      dataPorts: [],
      exceptionPorts: []
    };

    graph.link(op,g,this.inputs,    "input", "green","inventory","io",  "from");
    graph.link(op,g,this.outputs,   "output","pink","inventory","io",  "to");
    graph.link(op,g,this.parameters,"data", "blue", "inventory","data","from");
    graph.link(op,g,this.data,      "data", "cyan", "inventory","data","to");

    graph.link(op,g,this.exceptions,"exception", "coral", "inventory","data","to");

    g.nodeDataArray.push(op);

  });

  $.each(this.workflow.io,function() {
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

    g.nodeDataArray.push({
      key: op.key + "_" + this.name,
      name: this.name,
      category: nodeType,
      color: lc,
      data: this
    });

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
