WorkflowEditor.prototype.show_details = function(e) {

  var that = this;

  angular.element('#details').scope()

    .show(this.diagram.selection,function(node) {

      console.log(node);

      var old_name = node.data.name;
      node.data.name = node.data.workflow.name;
      that.diagram.startTransaction("changeName"); 
      that.diagram.model.raiseDataChanged(node.data, "name", old_name, node.data.name);
      that.diagram.commitTransaction("changeName");  

      that.diagram.isModified = true; // not working?

      document.getElementById("workflow-data").value = that.json();

    });

}
