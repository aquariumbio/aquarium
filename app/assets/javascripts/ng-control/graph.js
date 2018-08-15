(function() {

  var w = angular.module('aquarium');

  w.controller('graphCtrl', [ '$scope', '$http',
                function (  $scope,   $http ) {

    AQ.init($http);
    AQ.update = () => { $scope.$apply(); }
    AQ.confirm = (msg) => { return confirm(msg); }

    $scope.nodes = [];
    $scope.edges = [];

    AQ.Sample.find(24545).then(
      sample => {
        expand(sample).then(edges => {
          $scope.edges = edges;
          $scope.nodes = extract_nodes(edges);
          $scope.$apply();

          var container = document.getElementById('graph');
          var data = {
              nodes: $scope.nodes,
              edges: $scope.edges
          };
          var options = {
            physics: {
                enabled: false
            },
            edges: {
              smooth: false,
              arrows: {
                to: {enabled: true, scaleFactor:1, type:'arrow'},
              }
            },
            layout: {
              hierarchical: {
                enabled: false,
                sortMethod: "hubsize",
                nodeSpacing: 100,
                sortMethod: "directed"
              }
            }
          };

          var network = new vis.Network(container, data, options);

        });

      }
    );

    function extract_nodes(edges) {
      let nodes = [];
      aq.each(edges, edge =>  {
        nodes.push(edge.from);
        nodes.push(edge.to);
      });
      return aq.collect(Array.from(new Set(nodes)), node => ({
        id: node,
        label: `${node.substring(1)}`,
        shape: node[0] == "o" ? 'box' : 'ellipse',
        color: node[0] == "o" ? '#eeeeee' : '#ccffcc'
      }));
    }

    function make_edges(operations, field_values) {
      let edges = [];
      aq.each(operations, op => {
        let inputs  = aq.where(field_values, fv => fv.role == "input"  && fv.parent_id == op.id),
            outputs = aq.where(field_values, fv => fv.role == "output" && fv.parent_id == op.id);
        aq.each(inputs, input => {
          aq.each(outputs, output => {
            if ( input.child_sample_id && output.child_sample_id && input.child_sample_id != output.child_sample_id) {
              edges.push({
                from: "s" + input.child_sample_id,
                to: "o" + op.id,
                color: "black"
              });
              edges.push({
                from: "o" + op.id,
                to: "s" + output.child_sample_id,
                color: "black"
              });
            }
          });
        });
      });
      return edges;
    }

    function expand(sample) {

      let ops = [];

      return AQ.FieldValue
        .where({parent_class: "Operation", child_sample_id: sample.id})
        .then(fvs => AQ.Operation.where({id: aq.collect(fvs, fv => fv.parent_id)}))
        .then(operations => { ops = operations;
                              return AQ.FieldValue.where({
                                parent_class: "Operation",
                                parent_id: aq.collect(operations, op => op.id)
                              })
                            })
        .then(field_values => make_edges(ops, field_values))

    }

  }]);

})();
