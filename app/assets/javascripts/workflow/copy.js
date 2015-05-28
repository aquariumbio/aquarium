//
// I am not sure if any of this is needed. 
//

WorkflowEditor.prototype.copyNodeData = function(data) {

  var copy = {};

  copy.key = data.key;  
  copy.loc = data.loc;
  copy.category = data.category;

  if ( data.category == "operation" ) {
    copy.leftArray   = this.copyPortArray(data.leftArray); 
    copy.rightArray  = this.copyPortArray(data.rightArray);
    copy.topArray    = this.copyPortArray(data.topArray); 
    copy.bottomArray = this.copyPortArray(data.bottomArray); 
  }
  console.log([data,copy]);
  return copy;

}

WorkflowEditor.prototype.copyPortArray = function(arr) {

  var copy = [];
  if (Array.isArray(arr)) {
    for (var i = 0; i < arr.length; i++) {
      copy.push(this.copyPortData(arr[i]));
    }
  }
  return copy;

}

WorkflowEditor.prototype.copyPortData = function(data) {

  var copy = {};
  copy.portId = data.portId;
  copy.portColor = data.portColor;
  // if you add port data properties, you should copy them here too
  
  return copy;

}