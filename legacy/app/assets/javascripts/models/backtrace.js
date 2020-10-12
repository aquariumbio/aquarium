class Step {

  constructor(display,response) {

    let step = this;

    step.display = display;

    aq.each(step.display.content, line => {
      line._id = step.next_line_id;
      if ( !AQ.config.no_items_in_backtrace && line.take && line.take.id ) {
        AQ.Item.find(line.take.id).then(item => line.take = item);
      }      
    });

    if ( response ) {
      step.response = response;
    } else {
      step.response = { inputs: {} };
    }
    step.type = step.display.operation

    if ( step.type == "display" ) {

      if ( !response ) {
        step.response = step.new_response();
      } else {
        step.response = step.marshall_response();
      }

      //Keeping track of which substep user is focused on
      step.substep_index = -1;
      step.substeps = step.display.content.filter(line => line.check || line.input || line.table || line.select)
      step.substeps = step.substeps.map(line => (line.table ? line.table.flat().filter(cell => cell.check || cell.type) : line)).flat()
    }
  }

  get next_line_id() {
    if ( !this.constructor.next_line_id ) {
      this.constructor.next_line_id = 0;
    }
    return this.constructor.next_line_id++;
  }  

  get ready() {
    let step = this;
    for ( var j=0; j<step.display.content.length; j++ ) {
      let line = step.display.content[j];
      if ( line && line.check && !line.checked ) {
        return false;
      }
      if ( line && line.table ) {
        for ( var x=0; x<line.table.length; x++ ) {
          for ( var y=0; y<line.table[x].length; y++ ) {
            if ( line.table[x][y].check && !line.table[x][y].checked ) {
              return false;
            }
          }
        }
      }
    }  
    return true;
  }

  get title() {
    switch(this.type) {
      case "display":
        if ( this.display.content && this.display.content[0].title ) {
          return this.display.content[0].title
        } else {
          return "(Untitled Step)"
        }
        break;
      case "error":
        return "Runtime Error";
        break;      
      case "aborted":
        return "Job Canceled";
        break;
      case "complete": 
        return "Complete";
    }
  }

  check_all() {
    let step = this;
    for ( var j=0; j<step.display.content.length; j++ ) {
      let line = step.display.content[j];
      if ( line && line.check ) {
        line.checked = true;
      }
      if ( line && line.table ) {
        for ( var x=0; x<line.table.length; x++ ) {
          for ( var y=0; y<line.table[x].length; y++ ) {
            if ( line.table[x][y].check ) {
              line.table[x][y].checked  = true;
            }
          }
        }
      }
    }  
    return true;    
  }

  // Checks the next checkable substep and sets focus to next input box if applicable
  check_next() {
    let step = this;
    if (!step.substeps || (step.substep_index == step.substeps.length - 1)) {
      return false;
    }

    let prev_substep = step.substeps[step.substep_index];
    let substep = step.substeps[step.substep_index + 1];
    let next_substep = step.substeps[step.substep_index + 2];

    if (prev_substep && !prev_substep.check) {
      prev_substep.focused = false;
    }

    if (substep) {
      if (substep.check) {
        substep.checked = true;
      } else {
        substep.focused = true;
      }
    }

    step.substep_index ++;
    if(substep && next_substep && substep.check && !next_substep.check) {
      step.check_next();
    }
    return true;
  }

  // unchecks current checkbox and sets focus to previous input box if applicable
  uncheck_prev() {
    let step = this;
    if (!step.substeps || (step.substep_index == -1)) {
      return false;
    }

    let prev_substep = step.substeps[step.substep_index - 1];
    let substep = step.substeps[step.substep_index];

    if (prev_substep && !prev_substep.check) {
        prev_substep.focused = true;
    }

    if (substep) {
      if (substep.check) {
        substep.checked = false;
      } else {
        substep.focused = false;
      }
    }

    step.substep_index --;
    if (substep && prev_substep && !substep.check && prev_substep.check) {
      step.uncheck_prev();
    }
    return true;
  }

  new_response() {

    let step = this;

    step.response = { in_progress: true, inputs: { table_inputs:[] } }

    for ( var j=0; j<step.display.content.length; j++ ) {

      let line = step.display.content[j];

      if ( line ) {

        if ( line.select ) {
          step.response.inputs[line.select.var] = line.select.choices[line.select.default];
        }
        if ( line.input ) {
          step.response.inputs[line.input.var] = line.input.default;
        }   
        if ( line.table ) {
          step.response.inputs.table_inputs = step.new_table_inputs(line);
        }

      }

    }

    return step.response;
  }

  new_table_inputs(line) {

    var table_inputs = {};

    for ( var j=0; j < line.table.length; j++ ) {
      for ( var k=0; k < line.table[j].length; k++ ) {
        if ( line.table[j][k].key ) {
          if ( !table_inputs[line.table[j][k].key] ) {
            table_inputs[line.table[j][k].key] = {};
          }
          table_inputs[line.table[j][k].key][line.table[j][k].operation_id] = {
            value: line.table[j][k].default,
            type: line.table[j][k].type,
            row: (j - 1) //j is 1-based, we want the row field to be zero based
          }
        }
      }
    }

    return table_inputs;

  }   

  marshall_response() {

    // Backend returns [ { opid: __, key: __, value: __, type: __}, ...]
    // Frontend wants { key1: { opid1: { ... }, opid2: { ... } }, key2: { ... } }

    let step = this,
        frontend_table_inputs = {},
        backend_table_inputs;

    if ( !step.response.inputs ) {
      step.response.inputs = { table_inputs: [] }
    }

    backend_table_inputs = step.response.inputs.table_inputs;

    if ( backend_table_inputs ) {

      for ( var i=0; i< backend_table_inputs.length; i++ ) {
        if ( !frontend_table_inputs[backend_table_inputs[i].key] ) {
          frontend_table_inputs[backend_table_inputs[i].key] = {}
        }
        frontend_table_inputs[backend_table_inputs[i].key][backend_table_inputs[i].opid] = {
          value: backend_table_inputs[i].value,
          type: backend_table_inputs[i].type
        }
      }

    }

    step.response.inputs.table_inputs = frontend_table_inputs;

    return step.response;

  }

  // TODO: distinguish table inputs by row, rather than by opid. Then add opid as 
  // an optional attribute of that table input.
  // This change will involve touching:
  // the method below
  // new_table_inputs
  // _show_block.html.erb in both operations and technician
  prepare_table_inputs() {

    var backend_table_inputs = [],
        frontend_table_inputs = this.response.inputs.table_inputs;

    for ( var key in frontend_table_inputs ) {
      for (var opid in frontend_table_inputs[key]) {
        backend_table_inputs.push({ 
          key: key, 
          opid: parseInt(opid),
          row: frontend_table_inputs[key][opid].row,
          value: frontend_table_inputs[key][opid].value,
          type: frontend_table_inputs[key][opid].type
        });
      }
    }

    return backend_table_inputs;

  }

  sendable_response() {
    let inputs = this.response.inputs;
    inputs.table_inputs = this.prepare_table_inputs();
    inputs.timestamp = Date.now()/1000;
    this.response.inputs = inputs;
    return this.response;
  }

  get timer() {
    for ( var i in this.display.content ) {
      if ( this.display.content[i].timer ) {
        return this.display.content[i].timer;
      }
    }
    return undefined;
  }

}


class Backtrace { // This should extend array, but the closure compiler used in
                  // production doesn't let you do that.
  
  constructor(state) {

    let backtrace = this;
    backtrace.array = [];

    for ( var i=1; i<state.length; i+=2) {
      if ( state[i] ) {    
        backtrace.array.push(new Step(state[i], state[i+1]));
      }
    }

  }

  get complete() {

   let backtrace = this;

   return backtrace.array.length > 0 &&
          backtrace.array[backtrace.array.length-1].display &&
          backtrace.array[backtrace.array.length-1].display.operation != 'display';

  }

  get length() {
    return this.array.length;
  }

  get last() {
    let backtrace = this;
    return backtrace.array[backtrace.array.length-1];
  }

  get second_to_last() {
    let backtrace = this;
    return backtrace.array[backtrace.array.length-2];
  }  

  get ready() {
    if ( this.last ) {
      return this.last.ready;
    } else {
      return false;
    }
  }

  get last_response() {

    var backtrace = this;
    return backtrace.last.sendable_response();

  }

}
