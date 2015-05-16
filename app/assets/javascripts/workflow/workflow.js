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

  var that = this;

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
      dataPorts: []
    };

    $.each(this.inputs,function() { // Inputs ////////////////////////////////////////////
      op.inputPorts.push({
        portId: this.name,
        portColor: "orange"
      });
      g.nodeDataArray.push({
        key: that.id + "_" + this.name,
        name: this.name,
        category: "inventory",
        color: "lightBlue",
        data: this
      });
      g.linkDataArray.push({
        to: that.id,
        from: that.id + "_" + this.name,
        toPort: this.name,
        category: "io",
        fromSpot: go.Spot.Bottom
      });
    });

    $.each(this.outputs,function() { // Outputs //////////////////////////////////////////
      op.outputPorts.push({
        portId: this.name,
        portColor: "blue"
      });
      g.nodeDataArray.push({
        key: that.id + "_" + this.name,
        name: this.name,
        category: "inventory",
        color: "lightBlue",
        data: this
      });
      g.linkDataArray.push({
        from: that.id,
        to: that.id + "_" + this.name,
        fromPort: this.name,
        category: "io"
      });      
    });

    $.each(this.parameters,function() { // Parameters ////////////////////////////////////
      op.paramPorts.push({
        portId: this.name,
        portColor: "green"
      });
      g.nodeDataArray.push({
        key: that.id + "_" + this.name,
        name: this.name,
        category: "inventory",
        color: "lightGreen",
        data: this
      });
      g.linkDataArray.push({
        to: that.id,
        from: that.id + "_" + this.name,
        toPort: this.name,
        category: "data",
        fromSpot: go.Spot.Right
      });      
    });    

    g.nodeDataArray.push(op);

  });

  $.each(this.workflow.io,function() {
    g.linkDataArray.push({
      from: this.from[0] + "_" + this.from[1],
      to: this.to[0] + "_" + this.to[1],
      category: "identification"
    });
  });

  console.log(g);

  return go.Model.fromJson(g);  

}

