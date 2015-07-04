WorkflowEditor.prototype.drop_inventory = function() {

  var that = this;
  var nodes = [];
  var ports = [];

  this.diagram.selection.each(function(node) {

    if (!(node instanceof go.Node)) return;

    if ( node.data.category == "inventory" ) {

      nodes.push(node);

      node.findLinksConnected().each(function(link) {

        if ( link.fromNode.data.category == "operation" ) {
          ports.push(link.fromPort);
        }

        if ( link.toNode && link.toNode.data.category == "operation" ) {
          ports.push(link.toPort);
        }

      });

    }

  });


  var opid = nodes[0].data.key.split('_')[0],
      type = nodes[0].data.type != 'data' ? nodes[0].data.type + "s" : nodes[0].data.type;

  $.ajax ( "/operations/" + opid + "/drop_part?type=" + type + "&name=" + nodes[0].data.name )
    .done(function() {
      that.diagram.startTransaction("dropInv");  
      that.diagram.remove(nodes[0]);
      that.removePort(ports[0]);
      that.diagram.commitTransaction("dropInv");   
    });

}

WorkflowEditor.prototype.removePort = function(port) {

  this.diagram.startTransaction("removePort");
  var pid = port.portId;
  var arr = port.panel.itemArray;

  for (var i = 0; i < arr.length; i++) {
    if (arr[i].portId === pid) {
      this.diagram.model.removeArrayItem(arr, i);
      break;
    }
  }

  this.diagram.commitTransaction("removePort");

}

WorkflowEditor.prototype.drop_operation = function() {

  var that = this;
  var nodes = [];

  this.diagram.selection.each(function(node) {

    if (!(node instanceof go.Node)) return;

    if ( node.data.category == "operation" ) {
      nodes.push(node);
      node.findNodesConnected().each(function(inv_node) {
        nodes.push(inv_node);
      });
    }

  });

  for ( var i=0; i<nodes.length; i++ ) {

    if ( nodes[i].data.category == "operation" ) {

      (function(n) {
        $.ajax('/workflows/'+that.workflow.id+'/drop_operation/'+n.data.id).done(function() {
          that.diagram.startTransaction("dropOp"+i);
          that.diagram.remove(n);
          that.diagram.commitTransaction("dropOp"+i);    
        });
      })(nodes[i]);

    } else {
      that.diagram.startTransaction("dropOp"+i);
      that.diagram.remove(nodes[i]);
      that.diagram.commitTransaction("dropOp"+i);         
    }

  }

}





