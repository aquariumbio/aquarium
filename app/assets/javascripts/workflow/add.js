WorkflowEditor.prototype.addInventorySpec = function (type) {

  var that = this;
  var real_type = type == "parameters" ? "data" : type;

  this.diagram.selection.each(function(node) {

    if (!(node instanceof go.Node)) return;

    var portname = ({ inputs: "inputPorts", outputs: "outputPorts", 
                      data: "dataPorts", parameters: "dataPorts"})[type];

    var arr = node.data[portname];

    if (arr) {

      $.ajax("/operations/" + node.data.id + "/new_part.json?type=" + type).done(function(result) {

        console.log(data);

        var name = result.name;

        $.extend(node.data,result.operation);

        that.diagram.startTransaction("addInv");

        var newportdata = {
          portId: name,
          portColor: "#af2"
        };

        that.diagram.model.insertArrayItem(arr, -1, newportdata);

        var inventoryNodeData = {
          key: type + that.currentID++,
          name: name,
          category: "inventory", 
          color: "#eee",
          type: type
        };

        that.diagram.model.addNodeData(inventoryNodeData);

        var link_type = type == "inputs" || type == "outputs" ? "io" : "data";

        if ( type == "inputs" || type == "parameters" ) {

          that.diagram.model.addLinkData({
            to: node.data.key, from: inventoryNodeData.key, toPort: name, category: link_type
          });

        } else {

          that.diagram.model.addLinkData({
            from: node.data.key, to: inventoryNodeData.key, fromPort: name, category: link_type
          });

        }

        that.diagram.commitTransaction("addInv"); 

      });

    }

  });

}

WorkflowEditor.prototype.addInput = function (e,obj) {
  this.addInventorySpec("inputs");
}

WorkflowEditor.prototype.addOutput = function(e,obj) {
  this.addInventorySpec("outputs");
}

WorkflowEditor.prototype.addParameter = function(e,obj) {
  this.addInventorySpec("parameters");
}

WorkflowEditor.prototype.associateData = function(e,obj) {
  this.addInventorySpec("data");
}

WorkflowEditor.prototype.addOperation = function() {

  var that = this;

  $.ajax("/workflows/"+this.workflow.id+"/new_operation.json").done(function(data) {

    that.diagram.startTransaction("addOp");     

    var r = $.extend({},data,{
      key: data.id,
      category: "operation", 
      inputPorts: [], 
      outputPorts: [], 
      dataPorts: [], 
      parameterPorts: [], 
      exceptionPorts: []
    });

    that.diagram.model.addNodeData(r);
    that.diagram.commitTransaction("addOp"); 

  });

}

WorkflowEditor.prototype.identifyIO = function() {

  var that = this;
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

    var source = output.data.key.split("_")[0],
        dest = input.data.key.split("_")[0];

    $.ajax("/workflows/"+this.workflow.id+"/identify.json?source="
           +source+"&dest="+dest+"&output="+output.data.name+"&input="+input.data.name).done(

      function(result) {

        that.diagram.startTransaction("identifyIO"); 

        that.diagram.model.addLinkData({
          to: input.data.key, from: output.data.key, category: "identification"
        });

        console.log({
          to: input.data.key, from: output.data.key, category: "identification"
        });

        that.diagram.commitTransaction("identifyIO");   

      });

  } else {

    console.log("Cannot combine selected inventory specifications.");

  }


}