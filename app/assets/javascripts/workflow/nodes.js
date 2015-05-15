
WorkflowEditor.prototype.define_nodes = function() {
  this.define_operation_node();
  this.define_inventory_node(); 
}

WorkflowEditor.prototype.operation_port = function(side,r,c,spot,direction) {
  return o(go.Panel, direction, new go.Binding("itemArray", side+"Array"),
      { row: r, column: c,
       itemTemplate:
         o(go.Panel,
           { _side: side,  
             fromSpot: spot, toSpot: spot,
             fromLinkable: false, toLinkable: true, cursor: "pointer" },
         new go.Binding("portId", "portId"),
         o(go.Shape, "Circle",
           { stroke: null,
             desiredSize: new go.Size(8, 8),
             margin: new go.Margin(0,0) 
           },
           new go.Binding("fill", "portColor"))
      )  
    }
  )
}

WorkflowEditor.prototype.define_operation_node = function() {

  var that = this;

  var nodeMenu =  // context menu for each Node
    o(go.Adornment, "Vertical",
      o("ContextMenuButton", o(go.TextBlock, "Add input"),      { click: function(e,obj) { that.addInput(); } } ),
      o("ContextMenuButton", o(go.TextBlock, "Add output"),     { click: function(e,obj) { that.addOutput(); } } ),
      o("ContextMenuButton", o(go.TextBlock, "Associate data"), { click: function(e,obj) { that.associateData(); } } ),
      o("ContextMenuButton", o(go.TextBlock, "Delete"), { click: function(e,obj) { that.drop_operation(); } } )      
    );

  this.diagram.nodeTemplateMap.add("operation",

    o(go.Node, "Table",

      { locationObjectName: "BODY", 
        locationSpot: go.Spot.Center, 
        selectionObjectName: "BODY",
        contextMenu: nodeMenu },

      new go.Binding("location", "loc", go.Point.parse).makeTwoWay(go.Point.stringify),

      // the body
      o(go.Panel, "Auto",
        { row: 1, column: 1, name: "BODY", stretch: go.GraphObject.Fill },
        o(go.Shape, "RoundedRectangle", { fill: "#fff", minSize: new go.Size(75, 32) }),
        o(go.TextBlock, { margin: 3, textAlign: "center" }, new go.Binding("text", "name"))
      ),

      this.operation_port  ( "left", 1, 0, go.Spot.Left, "Vertical" ),
      this.operation_port  ( "right", 1, 2, go.Spot.Right, "Vertical" ),
      this.operation_port  ( "top", 0, 1, go.Spot.Top, "Horizontal" ),
      this.operation_port  ( "bottom", 2, 1, go.Spot.Bottom, "Horizontal" )        

    )
    
  );

}

WorkflowEditor.prototype.define_inventory_node = function() {

  var that = this;

  var nodeMenu =  // context menu for each Node
    o(go.Adornment, "Vertical",
      o("ContextMenuButton", o(go.TextBlock, "Identify"), { click: function(e,obj) { that.identifyIO(); } } ),
      o("ContextMenuButton", o(go.TextBlock, "Delete"),   { click: function(e,obj) { that.drop_inventory(); } } )      
    );  

  this.diagram.nodeTemplateMap.add("inventory",
    o(go.Node, "Auto", 
    { contextMenu: nodeMenu },
      o(go.Shape, "RoundedRectangle", new go.Binding("fill", "color"), 
        { strokeWidth: 1, strokeJoin: "round" }),
      o(go.TextBlock, { margin: 0 }, new go.Binding("text", "name"))
    )
  );  

}
