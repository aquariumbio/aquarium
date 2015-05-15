WorkflowEditor.prototype.define_links = function() {

  this.diagram.linkTemplateMap.add("io",
    o(go.Link,
      { routing: go.Link.Orthogonal, corner: 20, curve: go.Link.JumpGap  },
      o(go.Shape, { strokeWidth: 2, stroke: "#555" })
    )
  )

  this.diagram.linkTemplateMap.add("identification",
    o(go.Link,
      { routing: go.Link.Orthogonal, corner: 20 },
      o(go.Shape, { strokeWidth: 6, stroke: "lightBlue", strokeDashArray: [2,2] })
    )
  )  
  
}