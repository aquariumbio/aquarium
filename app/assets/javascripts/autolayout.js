function PN() {
}

PN.prototype.buildGraph = function(pn) {

    var elements = [];
    var links = [];

    var that = this;
    
    _.each(pn.places,function(p) {
	elements.push(that.makePlace(p));
    });

    var i = 0;
    _.each(pn.transitions,function(t) {
        elements.push(that.makeTrans("T"+i));
        _.each(t.preset,function(p) {
            links.push(that.makeLink(p,"T"+i));
        });
        _.each(t.postset,function(p) {
            links.push(that.makeLink("T"+i,p));
        });

        i++;
    });

    return elements.concat(links);

}

PN.prototype.makeLink = function(parentElementLabel, childElementLabel) {

    return new joint.dia.Link({
        source: { id: parentElementLabel },
        target: { id: childElementLabel },
        attrs: { '.marker-target': { d: 'M 4 0 L 0 2 L 4 4 z' } },
        smooth: false
    });
}

PN.prototype.makePlace = function(p) {

    var maxLineLength = _.max(p.name.split('\n'), function(l) { return l.length; }).length;

    var letterSize = 12;
    var width = 1.05 * (letterSize * (0.6 * maxLineLength + 1));
    var height = 1.05 * ((p.name.split('\n').length + 1) * letterSize);
    var fill = '#fff';

    if ( p.marking > 0 ) {
      fill = '#ffa';
    } 

    return new joint.shapes.basic.Rect({
        id: p.name,
        size: { width: width, height: height },
        attrs: {
            text: { text: p.name, 'font-size': letterSize, 'font-family': 'helvetica' },	    
            rect: {
                width: width, height: height,
                rx: 5, ry: 5,
                stroke: '#555',
                fill: fill
            }
        }
    });

}

PN.prototype.makeTrans = function(label) {

    var width = 14;
    var height = 14;

    return new joint.shapes.basic.Rect({
        id: label,
        size: { width: width, height: height },
        attrs: {
            rect: {
                width: width,
                height: height,
                fill: '#fff',
                stroke: '#000'
            }
        }
    });

}

PN.prototype.layout = function(pn) {
    
    var graph = new joint.dia.Graph;

    var paper = new joint.dia.Paper({ 
        el: $('#paper'),
        width: 500,
        height: 1200,
        gridSize: 1,
        model: graph
    });

    var cells = this.buildGraph(pn);

    graph.resetCells(cells);
    joint.layout.DirectedGraph.layout(graph, { setLinkVertices: false });

}
