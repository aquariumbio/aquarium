
WorkflowEditor.prototype.define_nodes = function() {
  this.define_operation_node();
  this.define_inventory_node(); 
}

WorkflowEditor.prototype.operation_port = function(name) {

  return o(go.Panel, this.geom[name].dir, new go.Binding("itemArray", name+"Ports"),
      { row: this.geom[name].x, column: this.geom[name].y,
       itemTemplate:
         o(go.Panel,
           { _side: this.geom[name].side,  
             fromSpot: this.geom[name].spot, toSpot: this.geom[name].spot },
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

  this.geom = {
    input:  { side: "top",    spot: go.Spot.Top,    x: 0, y: 1, dir: "Horizontal" },
    output: { side: "bottom", spot: go.Spot.Bottom, x: 2, y: 1, dir: "Horizontal" },
    data:  { side: "left",    spot: go.Spot.Left,   x: 1, y: 0, dir: "Vertical" },
    exception:  { side: "right",    spot: go.Spot.Right,   x: 1, y: 2, dir: "Vertical" }        
  }

  var nodeMenu =  // context menu for each Node
    o(go.Adornment, "Vertical",
      o("ContextMenuButton", o(go.TextBlock, "Add input"),      { click: function(e,obj) { that.addInput(); } } ),
      o("ContextMenuButton", o(go.TextBlock, "Add output"),     { click: function(e,obj) { that.addOutput(); } } ),
      o("ContextMenuButton", o(go.TextBlock, "Add Parameter"),  { click: function(e,obj) { that.addParameter(); } } ),      
      o("ContextMenuButton", o(go.TextBlock, "Associate data"), { click: function(e,obj) { that.associateData(); } } ),
      o("ContextMenuButton", o(go.TextBlock, "Delete"),         { click: function(e,obj) { that.drop_operation(); } } )      
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

      this.operation_port  ( "input" ),
      this.operation_port  ( "output" ),
      this.operation_port  ( "data" ),
      this.operation_port  ( "exception" )
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
