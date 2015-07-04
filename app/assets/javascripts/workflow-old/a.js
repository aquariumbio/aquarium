function WorkflowEditor(wid,view_tag,data_tag) {

  var that = this;

  this.diagram = o(go.Diagram, view_tag, {
    initialContentAlignment: go.Spot.Center, 
    "undoManager.isEnabled": true 
  });

  this.currentID = 0;

  this.set_style();
  this.define_nodes();
  this.define_links();

  this.diagram.addDiagramListener("Modified", function(e) {
    var button = document.getElementById("SaveButton");
    if (button) button.disabled = !that.diagram.isModified;
  });

  this.diagram.addDiagramListener("ChangedSelection", function(e) {
    that.show_details(e);
  });  

  this.diagram.initialContentAlignment = go.Spot.Center;
  this.diagram.undoManager.isEnabled = true;

  this.diagram.layout = o(go.LayeredDigraphLayout,{
    direction: this.style.diagram.direction,
    layerSpacing: this.style.diagram.layerSpacing,
    layeringOption: go.LayeredDigraphLayout.LayerOptimalLinkLength,
    packOption: go.LayeredDigraphLayout.PackStraighten,
    setsPortSpots: false
  });

  this.diagram.contextMenu = 
   o(go.Adornment, "Vertical",
     o("ContextMenuButton", o(go.TextBlock, "Add operation"),  { click: function(e,obj) { that.addOperation(); } } ),
     o("ContextMenuButton",
       o(go.TextBlock, "Undo"),
       { click: function(e, obj) { e.diagram.commandHandler.undo(); } },
       new go.Binding("visible", "", function(o) {
           return o.diagram.commandHandler.canUndo();
         }).ofObject()),
     o("ContextMenuButton",
       o(go.TextBlock, "Redo"),
       { click: function(e, obj) { e.diagram.commandHandler.redo(); } },
       new go.Binding("visible", "", function(o) {
           return o.diagram.commandHandler.canRedo();
         }).ofObject())
   );

  this.diagram.model.linkToPortIdProperty = "toPort";
  this.diagram.model.linkFromPortIdProperty = "fromPort";
  //this.diagram.model.copyNodeDataFunction = function(data) { that.copyNodeData(data) };
  
  // model
  this.workflow = new Workflow(wid);

  this.workflow.get().then(function(){
    angular.element('#details').scope().init(that.workflow);
    that.diagram.model = that.workflow.graph();
  });

}

WorkflowEditor.prototype.json = function() {
  this.diagram.isModified = false;  
  return this.diagram.model.toJson();
}
