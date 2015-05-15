WorkflowEditor.prototype.addInventorySpec = function (side) {

  var that = this;

  this.diagram.startTransaction("addInv"); 

  this.diagram.selection.each(function(node) {

    if (!(node instanceof go.Node)) return;

    var i = 0;
    while (node.findPort(side + i.toString()) !== node) i++;

    var name = side + i.toString();
    var arr = node.data[side + "Array"];

    if (arr) {

      var newportdata = {
        portId: name,
        portColor: "#295"
      };

      that.diagram.model.insertArrayItem(arr, -1, newportdata);

      var inventoryNodeData = {
        key: "inventory" + that.currentID++,
        name: "inventory",
        category: "inventory", 
        color: "lightBlue",
        type: side == "top" ? "input" : "output"
      };

      that.diagram.model.addNodeData(inventoryNodeData);

      if (side == "top" ) {

        that.diagram.model.addLinkData({
          to: node.data.key, from: inventoryNodeData.key, toPort: name, category: "io"
        });

      } else {

        that.diagram.model.addLinkData({
          from: node.data.key, to: inventoryNodeData.key, fromPort: name, category: "io"
        });

      }

    }
  });

  this.diagram.commitTransaction("addInv"); 

}


WorkflowEditor.prototype.addInput = function (e,obj) {
  this.addInventorySpec("top");
}

WorkflowEditor.prototype.addOutput = function(e,obj) {
  this.addInventorySpec("bottom");
}

WorkflowEditor.prototype.associateData = function(e,obj) {
  console.log("associating data");
  console.log([e,obj]);
}

WorkflowEditor.prototype.addOperation = function() {

  this.diagram.model.addNodeData({
    key: "operation",
    name: "op",
    category: "operation", 
    color: "lightBlue","leftArray":[  ], "rightArray":[  ], "topArray":[  ], "bottomArray":[  ]
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