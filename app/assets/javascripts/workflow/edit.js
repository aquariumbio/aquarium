WorkflowEditor.prototype.show_details = function(e) {

  var that = this;

  angular.element('#details').scope().show(this.diagram.selection,function(ev,node) {


    if ( ev == "rename_op" ) {

      $.ajax("/operations/" + node.data.id + "/rename.json?name="+node.data.name).done(function() {
        that.diagram.startTransaction("changeName"); 
        that.diagram.model.raiseDataChanged(node.data,"name");
        that.diagram.commitTransaction("changeName");  
        that.diagram.isModified = true; // not working?
      });

    } else if ( ev == "rename_part" ) {

      console.log(node.data.inputs);

    }

  });

}

