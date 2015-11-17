(function() {

  var w;
  try {
    w = angular.module('folders'); 
  } catch (e) {
    w = angular.module('folders', ['puElasticInput']); 
  } 

  w.factory('threadBuilder', function() {

    this.init = function(scope) {
      this.scope = scope;
    }

    this.new_thread = function(form) {
      var thread = {};
      angular.forEach(form.inputs.concat(form.outputs), function(part) {
        if ( part.is_vector ) {
          thread[part.name] = { value: [ {} ], is_vector: true };
        } else {
          thread[part.name] = { value: "" };
        }
        thread[part.name].alternatives = part.alternatives;
      });
      angular.forEach(form.parameters, function(p) {
        thread[p.name] = angular.copy(p);
        if ( thread[p.name].type.choices ) {
          thread[p.name].value = thread[p.name].type.choices[0];
        }
        if ( thread[p.name].type.choices && thread[p.name].type.multiple ) {
          thread[p.name].value = {};
        }        
      }); 
      return thread;
    }

    this.make = function(workflow,part) {

      var that = this;

      if ( !this.scope.selection.thread_builders ) {
        this.scope.selection.thread_builders = [];
      }      

      this.scope.selection.thread_builders.push({
        thread: that.new_thread(workflow.form),
        parent_sample_role: part.name,
        workflow_id: workflow.id,
        workflow_name: workflow.name,
        open: true
      });

      this.scope.selection.open = true;

    }

    this.open = function(sample,builder) {
      this.scope.selection = sample;
      builder.open = true;
    }

    this.close = function(builder) {
      builder.open = false;
    }

    this.save = function(sample,builder) {
      console.log(builder);
    }

    this.new_sample = function(name,component,alternatives) {

      var that = this;
      console.log([name,component,alternatives])

      if ( alternatives.length > 0 && alternatives[0].sample_type ) {

        $.ajax({
          url: '/sample_types/' + alternatives[0].sample_type.split(':')[0] + ".json"
        }).done(function(sample_type) {
          var s = that.scope.newSampleTemplate(sample_type);
          s.name = that.scope.selection.name + "_"  + name;
          component.new_sample = s;
          that.scope.$apply();
        });

      } else {

        console.log("No alternatives to use to create new sample");

      }

    }

    this.no_new_sample = function(component) {
      component.new_sample = null;
    }

    this.cancel = function(sample,builder) {
      var i = sample.thread_builders.indexOf(builder);
      sample.thread_builders.splice(i,1);
      this.scope.selection = null;
    }    

    this.add_to_vector = function(component) {
      component.value.push({});    
    }

    this.remove_from_vector = function(component,index) {
      component.value.splice(index,1);
    }    

    this.parameter_height = function(component) {
      var h = "20px";
      if ( component.type.multiple ) {
        h = ""+20*component.type.choices.length+"px";
      }
      return h;
    }

    this.toggle_select = function(component,c) {
      component.value[c] = !component.value[c];
    }

    return this;

  });



  w.directive('autocomplete', function(focus) {

    return {

      restrict: 'A',

      scope: { alternatives: "=" },

      link: function($scope,$element) {

        if ( $scope.alternatives && $scope.alternatives.length > 0 && $scope.alternatives[0].sample_type ) {

          var stid = parseInt($scope.alternatives[0].sample_type.split(':')[0]);

          $.ajax({
            url: '/sample_list?id=' + stid
          }).done(function(samples) {
            $element.autocomplete({
              source: samples
            });
          });

        } else {
          console.log("WARNING: No Alternatives Given for element: " + JSON.stringify($element) );
        }

      }

    }

  });

})();
