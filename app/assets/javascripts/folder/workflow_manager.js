(function() {

  var w;
  try {
    w = angular.module('folders'); 
  } catch (e) {
    w = angular.module('folders', ['puElasticInput']); 
  } 

  w.factory('workflowManager', function() {

    this.init = function(scope) {
      this.scope = scope;
    }

    this.select = function(workflow) {
      this.scope.selection = workflow;
      if ( !workflow.open) { this.open(workflow); }
    }

    this.open = function(workflow) {

      this.scope.selection = workflow;
      workflow.open = true;
      var that = this;

      $.ajax({
        url: '/folders.json?method=threads&workflow_id='+workflow.id,
        dataType: 'json',
        contentType: 'application/json'
      }).success(function(data) {
        workflow.threads = data.threads;
        that.scope.$apply();
      });

    }

    this.close = function(workflow) {
      workflow.open = false;
    }

    this.select_thread = function(thread) {
      thread.selected = true;
    }

    this.deselect_thread = function(thread) {
      thread.selected = false;
    }

    this.select_all = function(workflow) {
      if ( workflow.threads.length > 0 && workflow.threads[0].selected ) {
        angular.forEach(workflow.threads,function(t) {
          t.selected = false
        })
      } else {
        angular.forEach(workflow.threads,function(t) {
          t.selected = true
        }) 
      }
    }       

    this.launch = function(workflow) {

      var that = this;
      var thread_ids = [];

      $('.selector').each(function(s) {
        if ($(this).prop('checked') ) {
          thread_ids.push($(this).data('thread-id'));
        }
      });

      angular.forEach(workflow.threads,function(thread) {
        if ( thread.selected ) {
          thread_ids.push(thread.id);
        }
      });

      if ( thread_ids.length > 0 ) {

        workflow.launching = true;

        $.ajax({
          url: '/workflow_processes',
          data: { workflow_id: workflow.id, thread_ids: thread_ids, debug: false },
          method: "POST"
        }).success(function(proc) {
            proc.num_threads = thread_ids.length;
            console.log(proc);
            if ( !workflow.messages ) {
              workflow.messages = [];
            }
            that.open(workflow);
            workflow.messages.push(proc);
            workflow.launching = false;
            that.scope.$apply();
        }).error(function() {
            console.log("Could not start process")
        });

      } else {
        console.log("No threads selected.")
      }

    }    

    return this;

  });

})();