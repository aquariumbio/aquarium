WorkflowEditor.prototype.addInventorySpec = function (type,color) {

  var that = this;

  var real_type = type == "param" ? "data" : type;

  var lc = "light" + color.toLowerCase().replace(/\b[a-z]/g, function(letter) {
    return letter.toUpperCase();
  });

  this.diagram.startTransaction("addInv"); 

  this.diagram.selection.each(function(node) {

    if (!(node instanceof go.Node)) return;

    var i = 0;
    while (node.findPort(real_type + i.toString()) !== node) i++;

    var name = type + i.toString();
    var arr = node.data[real_type+"Ports"];

    if (arr) {

      var newportdata = {
        portId: name,
        portColor: color
      };

      that.diagram.model.insertArrayItem(arr, -1, newportdata);

      var inventoryNodeData = {
        key: type + that.currentID++,
        name: type,
        category: "inventory", 
        color: lc,
        type: type
      };

      that.diagram.model.addNodeData(inventoryNodeData);

      var link_type = type == "input" || type == "output" ? "io" : "data";

      if ( type == "input" || type == "param" ) {

        that.diagram.model.addLinkData({
          to: node.data.key, from: inventoryNodeData.key, toPort: name, category: link_type
        });

      } else {

        that.diagram.model.addLinkData({
          from: node.data.key, to: inventoryNodeData.key, fromPort: name, category: link_type
        });

      }

    }
  });

  this.diagram.commitTransaction("addInv"); 

}


WorkflowEditor.prototype.addInput = function (e,obj) {
  this.addInventorySpec("input","green");
}

WorkflowEditor.prototype.addOutput = function(e,obj) {
  this.addInventorySpec("output","pink");
}

WorkflowEditor.prototype.addParameter = function(e,obj) {
  this.addInventorySpec("param","blue");
}

WorkflowEditor.prototype.associateData = function(e,obj) {
  this.addInventorySpec("data","cyan");
}

WorkflowEditor.prototype.addOperation = function() {

  this.diagram.model.addNodeData({
    key: "operation",
    name: "op",
    category: "operation", 
    color: "lightBlue","input":[  ], "output":[  ], "data":[  ], "parameters":[  ], "exceptions": []
  });

}

WorkflowEditor.prototype.identifyIO = function() {

  this.diagram.startTransaction("identifyIO"); 

  var input, output;
  var x = 0;
  this.diagram.selection.each(function(node) {
    x++;
    if (node.data.type == "input" ) {
      input = node;
    } else if ( node.data.type == "output" ) {
      output = node;
    }
  });

  if ( x == 2 && input && output ) {

    this.diagram.model.addLinkData({
      to: input.data.key, from: output.data.key, category: "identification"
    });

  } else {

    console.log("Cannot combine selected inventory specifications.");

  }

  this.diagram.commitTransaction("identifyIO");   

}