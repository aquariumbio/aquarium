WorkflowEditor.prototype.set_style = function(name) {

  this.style = {

    diagram: {
      direction: 90,
      layerSpacing: 1
    },

    node: {
      port: {
        input:     { side: "top",    spot: go.Spot.Top,    x: 0, y: 1, dir: "Horizontal" },
        output:    { side: "bottom", spot: go.Spot.Bottom, x: 2, y: 1, dir: "Horizontal" },
        data:      { side: "left",   spot: go.Spot.Left,   x: 1, y: 0, dir: "Vertical" },
        exception: { side: "right",  spot: go.Spot.Right,  x: 1, y: 2, dir: "Vertical" }
      }
    },

    link: {
      io: {
        strokeWidth: 1, 
        stroke: "#000"
      },
      identification: {
        strokeWidth: 2, 
        stroke: "darkGreen", 
        strokeDashArray: [1,1]
      }
    }

  }

}