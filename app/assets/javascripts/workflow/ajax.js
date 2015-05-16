WorkflowEditor.prototype.retrieve_workflow = function() {

  var that = this;

  this.workflow = $.ajax({
    url: "/workflows/"+that.workflow_id+".json"
  }).done(function(data) {
    console.log(data.specification);
    that.workflow = data.specification;
    that.workflow_name = data.name;
  });

}
