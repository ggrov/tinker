// global psgraph variables
var psgraphs, // records array
    currentPSGraphIndex, // index of the record currently used
    psgraph, // current psgraph(record) used
	currentTactic, // current graph tactic used
	currentIndex, // index of the graph currently displayed
	tacticList; // list of the graph tactics defined for the current psgraph

// svg width & height
var width = d3.select("div#graph").node().getBoundingClientRect().width,
	height = d3.select("div#graph").node().getBoundingClientRect().height;

// data arrays for the graph (different than the one found in records)
var nodes = [],
    edges = [];

// zoom/pan function
function zoomed(){
	graph.attr("transform", "translate(" + d3.event.translate + ")scale(" + d3.event.scale + ")");
}

// drag function (when starting)
function dragstarted() {
  d3.event.sourceEvent.stopPropagation();
}

// drag function
function dragged(d){
	d.x = d3.event.x;
	d.y = d3.event.y;
	updateGraph(0);
}

// zoom/pan behavior
var zoom = d3.behavior.zoom()
	.scaleExtent([0.2, 5])
	.on("zoom", zoomed);

// drag behavior
var drag = d3.behavior.drag()
	.origin(function(d) { return d; })
	.on("dragstart", dragstarted)
	.on("drag", dragged);

// tooltip behavior
var tip = d3.tip()
    .attr("class","tooltip")
    .offset([-15,0])
    .html(function(d){
        switch(d.type){
            case "G":
                return "Goal "+d.label+" : "+d.value;
                break;
            case "T_Atomic":
                var def = "";
                psgraph.atomic_tactics.forEach(function(entry){
                    if(entry.name == d.value) def = entry.tactic;
                });
                var res = def != "" ? "Atomic tactic "+d.value+"<br>Definition : "+def : "Atomic tactic "+d.value;
                return res;
                break;
            case "T_Graph":
                var branchType = "";
                var subgr = 0;
                psgraph.graphs.forEach(function(entry){
                    if(entry.name == d.value){
                        branchType = entry.branch_type;
                        subgr = entry.graphs.length;
                    }
                });
                var res = branchType != "" ? "Graph tactic "+d.value+"<br>Branch type : "+branchType+"<br>Number of subgraphs : "+subgr : "Graph tactic "+d.value;
                return res;
                break;
        }
    })
    
// svg setup
var svg = d3.select("div#graph").append("svg")
	.attr("width","100%")
	.attr("height","100%")
	.append("g")
	.attr("transform", "translate(" + width/2 + "," + height/2 + ")")
	.call(zoom)
    .call(tip);

// dummy rect to catch zoom/pan action on graph 
var rect = svg.append("rect")
    .attr("width", "100%")
    .attr("height", "100%")
    .style("fill", "none")
    .style("pointer-events", "all")
	.attr("transform", "translate(" + (-width/2) + "," + (-height/2) + ")");

// actual graph object's group
var graph = svg.append("g");

// appending a marker for edge arrows
svg.append("svg:defs")
	.append("svg:marker")
		.attr("id", "end-arrow")
		.attr("viewBox", "0 -5 10 10")
		.attr("refX", 10)
		.attr("markerWidth", 6)
		.attr("markerHeight", 6)
		.attr("orient", "auto")
		.append("svg:path")
			.attr("fill", "#333")
			.attr("d", "M0,-5L10,0L0,5");

// dummy labels : used to mesure size of text
var dummyLabelText = svg.append("text").attr("class","label").style("opacity",0),
    dummyLabelBreakText = svg.append("text").attr("class","labelBreak").style("opacity",0),
    dummyLabelEdgeText = svg.append("text").attr("class","labelEdge").style("opacity",0);

// function refining the original graph data for display
function refineGraphData(initialData){
	
	function argumentsToString(arguments){
		function argToStr(argument){
			res = argument[0]
			if(argument.length > 1){
				res += ":"
				for(var i = 1; i < argument.length; i++){
					res += " "+argument[i]
				}
			}
			return res
		}
		var res = ""
		arguments.forEach(function(arg){
			res += argToStr(arg)+", "
		})
		return res.slice(0,res.length-2)
	}
	
	nodes = []
	for(var id in initialData.wire_vertices){
		nodes.push(
			{id:id,
			 type:"Boundary",
			 label:"bound",
			 w:10,
			 h:10,
			 x:parseInt(initialData.wire_vertices[id].annotation.coord[0]*75),
			 y:-parseInt(initialData.wire_vertices[id].annotation.coord[1]*75)}
		)
	}
	for(var id in initialData.node_vertices){
		var x = initialData.node_vertices[id].annotation ? parseInt(initialData.node_vertices[id].annotation.coord[0]*75) : 0;
		var y = initialData.node_vertices[id].annotation ? -parseInt(initialData.node_vertices[id].annotation.coord[1]*75) : 0;
		var w = 10;
		var h = 10;
		var type = initialData.node_vertices[id].data.type;
		var label = null;
		var value = null;
		switch(type) {
			case "G":
				label = initialData.node_vertices[id].data.gn.name;
				value = initialData.node_vertices[id].data.gn.goal;
				dummyLabelText.text(label)
				w = dummyLabelText.node().getBBox().width + 20;
				break;
			case "T_Identity":
				label = "identity";
				w = 30;
				break;
			case "T_Atomic":
				label = initialData.node_vertices[id].data.label ?
					initialData.node_vertices[id].data.label :
					initialData.node_vertices[id].data.atm+"("+argumentsToString(initialData.node_vertices[id].data.args)+")";
				dummyLabelText.text(label)
				w = dummyLabelText.node().getBBox().width + 20;
				h = dummyLabelText.node().getBBox().height + 10;
				value = initialData.node_vertices[id].data.atm;
				break;
			case "T_Graph":
				label = initialData.node_vertices[id].data.label ?
					initialData.node_vertices[id].data.label :
					initialData.node_vertices[id].data.subgraph+"("+argumentsToString(initialData.node_vertices[id].data.args)+")";
				dummyLabelText.text(label)
				w = dummyLabelText.node().getBBox().width + 20;
				h = dummyLabelText.node().getBBox().height + 10;
				value = initialData.node_vertices[id].data.subgraph;
				break;
			case "G_Break":
				label = "STOP";
				dummyLabelBreakText.text(label)
				w = dummyLabelBreakText.node().getBBox().width + 8;
				break;
		}
		nodes.push(
			{id:id,
			 type:type,
			 x:x,
			 y:y,
			 w:w,
			 h:h,
			 label:label,
			 value:value}
		);
	}
	
	edges = []
	for(var id in initialData.dir_edges){
		var src, tgt;
		nodes.forEach(function(entry,index){
			if(entry.id == initialData.dir_edges[id].src) src = entry
			if(entry.id == initialData.dir_edges[id].tgt) tgt = entry
		})
		var label = initialData.dir_edges[id].data.gtyp
		dummyLabelEdgeText.text(label)
		var w = dummyLabelEdgeText.node().getBBox().width + 4
		var h = dummyLabelEdgeText.node().getBBox().height + 4
		edges.push({id:id,label:label,src:src,tgt:tgt,w:w,h:h})
	}
	edges.contains = function(src,tgt){
		var res = false;
		edges.forEach(function(entry){
			if(entry.src.id == src && entry.tgt.id == tgt) res = true;
		})
		return res;	
	}
}

// function displaying the graph
function updateGraph(duration){

    duration = (typeof duration === undefined) ? 0 : duration;
    
	var e = graph.selectAll("g.edge")
		.data(edges,function(d){return d.id+d.label+d.src.id+d.tgt.id});
	
	e.style("opacity",1);
	
	var enterEdge = e.enter().append("g")
		.attr("class","edge")
		.style("opacity",0);
	enterEdge.append("path")
		.attr("class","edge")
		.attr("marker-end","url(#end-arrow)");
	enterEdge.append("rect")
		.attr("class","labelEdge")
		.attr("width",function(d){return d.w})
		.attr("height",function(d){return d.h});
	enterEdge.append("text")
		.attr("class","labelEdge")
		.text(function(d){return d.label});

		
	var n = graph.selectAll("g.node")
		.data(nodes,function(d){return d.id+d.type+d.label});
	
	n.style("opacity",1)
		.transition()
		.duration(duration)
		.attr("transform", function(d){return "translate(" + d.x + "," + d.y + ")"});
	
	var enterNodes = n.enter().append("g")
		.attr("class","node")
		.attr("transform", function(d){return "translate(" + d.x + "," + d.y + ")"})
		.style("opacity",0)
        .style("cursor","move")
		.call(drag);
	
    var enterBounds = enterNodes.filter(function(d){return d.type == "Boundary"});
	enterBounds.append("rect")
		.attr("x",function(d){return -d.w/2})
		.attr("y",function(d){return -d.h/2})
		.attr("width",function(d){return d.w})
		.attr("height",function(d){return d.h})
        .style("opacity",0); // comment this line to make boundary visible
	
	var enterAtms = enterNodes.filter(function(d){return d.type == "T_Atomic"});
	enterAtms.append("rect")
		.attr("class","atm")
		.attr("x",function(d){return -d.w/2})
		.attr("y",function(d){return -d.h/2})
		.attr("width", function(d){return d.w})
		.attr("height", function(d){return d.h});
	enterAtms.append("text")
		.attr("class","label")
		.text(function(d) {return d.label;})
		.attr("y", function(d) {
			return 5;
		});
    enterAtms.on("mouseover",tip.show)
        .on("mouseout",tip.hide)
	
	var enterNsts = enterNodes.filter(function(d){return d.type == "T_Graph"});
	enterNsts.append("rect")
		.attr("class","nst")
		.attr("x",function(d){return -d.w/2+5})
		.attr("y",function(d){return -d.h/2+5})
		.attr("width", function(d){return d.w})
		.attr("height", function(d){return d.h});
	enterNsts.append("rect")
		.attr("class","nst")
		.attr("x",function(d){return -d.w/2})
		.attr("y",function(d){return -d.h/2})
		.attr("width", function(d){return d.w})
		.attr("height", function(d){return d.h});
	enterNsts.append("text")
		.attr("class","label")
		.text(function(d) {return d.label;})
		.attr("y", function(d) {
			return 5;
		});
    enterNsts.on("mouseover",tip.show)
        .on("mouseout",tip.hide)
	
	var enterGoals = enterNodes.filter(function(d){return d.type == "G"});
	enterGoals.append("circle")
		.attr("class", "goal")
		.attr("r", function(d){return d.w/2});
	enterGoals.append("text")
		.attr("class","label")
		.text(function(d) {return d.label;})
		.attr("y", function(d) {
			return 5;
		});
    enterGoals.on("mouseover",tip.show)
        .on("mouseout",tip.hide)
	
	var enterIds = enterNodes.filter(function(d){return d.type == "T_Identity"});
	enterIds.append("polygon")
		.attr("class","id")
		.attr("points",function(d){
			var points = getPolygonCoordinates([0,0],d.w/2,0,3);
			var res = "";
			points.forEach(function(entry){
				res += entry[0]+","+entry[1]+" ";
			});
			return res;
		});
	
	var enterBreaks = enterNodes.filter(function(d){return d.type == "G_Break"});
	enterBreaks.append("polygon")
		.attr("class","break")
		.attr("points",function(d){
			var points = getPolygonCoordinates([0,0],d.w/2,0.3927,8);
			var res = "";
			points.forEach(function(entry){
				res += entry[0]+","+entry[1]+" ";
			});
			return res;
		});
	enterBreaks.append("text")
		.attr("class","labelBreak")
		.text(function(d){return d.label})
		.attr("y",function(d) {
			return 4;
		});
	
	enterNodes.transition()
		.duration(duration)
		.style("opacity",1)
	
	n.exit().transition()
		.duration(duration)
		.style("opacity",0)
		.remove()
	
	e.transition()
		.duration(duration)
		.style("opacity",1);
	e.select("path.edge").transition()
		.duration(duration)
		.attr("d",function(d){
				var x1=d.src.x,y1=d.src.y,x2=d.tgt.x,y2=d.tgt.y;
				var start,end;
				if(d.src.id == d.tgt.id){
					switch(d.src.type){
						case "Boundary":
						case "T_Atomic":
						case "T_Graph":
							end = getContactPoint([[x1-50,y1-50],[x1,y1]],[[x1-d.src.w/2,y1-d.src.h/2],[x1+d.src.w/2,y1-d.src.h/2],[x1+d.src.w/2,y1+d.src.h/2],[x1-d.src.w/2,y1+d.src.h/2]]);
							start = getContactPoint([[x1,y1],[x1+50,y1-50]],[[x1-d.src.w/2,y1-d.src.h/2],[x1+d.src.w/2,y1-d.src.h/2],[x1+d.src.w/2,y1+d.src.h/2],[x1-d.src.w/2,y1+d.src.h/2]]);
							break;
						case "T_Identity":
							end = getContactPoint([[x1-50,y1-50],[x1,y1]],getPolygonCoordinates([x1,y1],d.src.w/2,0,3));
							start = getContactPoint([[x1,y1],[x1+50,y1-50]],getPolygonCoordinates([x1,y1],d.src.w/2,0,3));
							break;
						case "G_Break":
							end = getContactPoint([[x1-50,y1-50],[x1,y1]],getPolygonCoordinates([x1,y1],d.src.w/2,0.3927,8));
							start = getContactPoint([[x1,y1],[x1+50,y1-50]],getPolygonCoordinates([x1,y1],d.src.w/2,0.3927,8));
							break;
						case "G":
							end = getContactPoint([[x1-50,y1-50],[x1,y1]],getPolygonCoordinates([x1,y1],d.src.w/2,0,20));
							start = getContactPoint([[x1,y1],[x1+50,y1-50]],getPolygonCoordinates([x1,y1],d.src.w/2,0,20));
							break;
						default:
							end = [x1,y1];
							start = [x1,y1];
					}
					return "M "+start[0]+" "+start[1]+" A 20 20 0 1 0 "+end[0]+" "+end[1];
				} else {
					switch(d.src.type){
						case "Boundary":
						case "T_Atomic":
						case "T_Graph":
							start = getContactPoint([[x2,y2],[x1,y1]],[[x1-d.src.w/2,y1-d.src.h/2],[x1+d.src.w/2,y1-d.src.h/2],[x1+d.src.w/2,y1+d.src.h/2],[x1-d.src.w/2,y1+d.src.h/2]]);
							break;
						case "T_Identity":
							start = getContactPoint([[x2,y2],[x1,y1]],getPolygonCoordinates([x1,y1],d.src.w/2,0,3));
							break;
						case "G_Break":
							start = getContactPoint([[x2,y2],[x1,y1]],getPolygonCoordinates([x1,y1],d.src.w/2,0.3927,8));
							break;
						case "G":
							start = getContactPoint([[x2,y2],[x1,y1]],getPolygonCoordinates([x1,y1],d.src.w/2,0,20));
							break;
						default:
							start = [x1,y1];
					}
					switch(d.tgt.type){
						case "Boundary":
						case "T_Atomic":
						case "T_Graph":
							end = getContactPoint([[x1,y1],[x2,y2]],[[x2-d.tgt.w/2,y2-d.tgt.h/2],[x2+d.tgt.w/2,y2-d.tgt.h/2],[x2+d.tgt.w/2,y2+d.tgt.h/2],[x2-d.tgt.w/2,y2+d.tgt.h/2]]);
							break;
						case "T_Identity":
							end = getContactPoint([[x1,y1],[x2,y2]],getPolygonCoordinates([x2,y2],d.tgt.w/2,0,3));
							break;
						case "G_Break":
							end = getContactPoint([[x1,y1],[x2,y2]],getPolygonCoordinates([x2,y2],d.tgt.w/2,0.3927,8));
							break;
						case "G":
							end = getContactPoint([[x1,y1],[x2,y2]],getPolygonCoordinates([x2,y2],d.tgt.w/2,0,20));
							break;
						default:
							end = [x2,y2];
					}
					if(edges.contains(d.tgt.id,d.src.id)){
						var dr = Math.sqrt((start[0] - end[0]) * (start[0] - end[0]) + (start[1] - end[1]) * (start[1] - end[1]))
						return "M "+start[0]+" "+start[1]+" A "+dr+" "+dr+" 0 0,1 "+end[0]+" "+end[1];
					}
					else {
						return "M "+start[0]+" "+start[1]+" L "+end[0]+" "+end[1];
					}
				}
			});
	e.select("rect.labelEdge").transition()
		.duration(duration)
		.attr("x",function(d){
			if(d.src.id == d.tgt.id){
				return d.src.x - d.w/2;
			}
			else if(edges.contains(d.tgt.id,d.src.id)){
				return (d.src.x+d.tgt.x)/2 - d.w/2 - (d.src.y-d.tgt.y)/8;
			}
			else{
				return (d.src.x+d.tgt.x)/2 - d.w/2;
			}
		})
		.attr("y",function(d){
			if(d.src.id == d.tgt.id){
				return d.src.y - 45 - d.h/2;
			}
			else if(edges.contains(d.tgt.id,d.src.id)){
				return (d.src.y+d.tgt.y)/2 - d.h/2 + (d.src.x-d.tgt.x)/8;
			}
			else{
				return (d.src.y+d.tgt.y)/2 - d.h/2;
			}
		});
	e.select("text.labelEdge").transition()
		.duration(duration)
		.attr("x",function(d){
			if(d.src.id == d.tgt.id){
				return d.src.x;
			}
			else if(edges.contains(d.tgt.id,d.src.id)){
				return (d.src.x+d.tgt.x)/2 - (d.src.y-d.tgt.y)/8;
			}
			else {
				return (d.src.x+d.tgt.x)/2;
			}
		})
		.attr("y",function(d){
			if(d.src.id == d.tgt.id){
				return d.src.y - 42
			}
			else if(edges.contains(d.tgt.id,d.src.id)){
				return (d.src.y+d.tgt.y)/2 + 3 + (d.src.x-d.tgt.x)/8;
			}
			else {
				return (d.src.y+d.tgt.y)/2 + 3;
			}
		});
	
	e.exit().transition()
		.duration(duration)
		.style("opacity",0)
		.remove();
	
	
	function getPolygonCoordinates(center,scale,rotation,numberOfPoints){
		var res = []
		for(var i = 0; i < numberOfPoints; i++){
			var x1 = center[0]+(Math.sin(2*Math.PI*i/numberOfPoints)*scale)
			var y1 = center[1]-(Math.cos(2*Math.PI*i/numberOfPoints)*scale)
			var x = ((x1-center[0])*Math.cos(rotation))-((y1-center[1])*Math.sin(rotation))+center[0]
			var y = ((y1-center[1])*Math.cos(rotation))+((x1-center[0])*Math.sin(rotation))+center[1]
			res.push([x,y])
		}
		return res
	}
	
	function getContactPoint(segment,polygon) {
		var seg = [segment[1][0]-segment[0][0], segment[1][1]-segment[0][1]]
		var arraySeg = []
		for(var i = 0; i < polygon.length; i++){
			if(i == polygon.length-1){
				arraySeg.push([polygon[0][0]-polygon[i][0], polygon[0][1]-polygon[i][1], i, 0])
			} else {
				arraySeg.push([polygon[i+1][0]-polygon[i][0], polygon[i+1][1]-polygon[i][1], i, i+1])
			}
		}
		function rec(s,arr) {
			if(arr.length != 0){
				var t = (-s[1] * (segment[0][0] - polygon[arr[0][2]][0]) + s[0] * (segment[0][1] - polygon[arr[0][2]][1])) / (-arr[0][0] * s[1] + s[0] * arr[0][1])
				var u = (-arr[0][1] * (segment[0][0] - polygon[arr[0][2]][0]) + arr[0][0] * (segment[0][1] - polygon[arr[0][2]][1])) / (-arr[0][0] * s[1] + s[0] * arr[0][1])
				if(t >= 0 && t <= 1 && u >= 0 && u<= 1){
					return [segment[0][0] + (u * s[0]), segment[0][1] + (u * s[1])]
				} else {
					return rec(s,arr.slice(1))
				}
			} else {
				return segment[1]
			}
		}
		return rec(seg,arraySeg)
	}
}

// function loading graph data for display
function loadNewGraph(graphData){
    graphData = (typeof graphData === 'undefined') ? {} : graphData
	refineGraphData(graphData)
	updateGraph(500)
}

// function updating the graph navigation
function updateGraphNav(){
    d3.select("button#previousSubGraph").attr("disabled",null)
    d3.select("button#nextSubGraph").attr("disabled",null)
    if(currentIndex <= 0){
        d3.select("button#previousSubGraph").attr("disabled",true)
    }
    if(currentIndex >= currentTactic.graphs.length-1){
        d3.select("button#nextSubGraph").attr("disabled",true)
    }
    d3.select("span#graphIndices").text((currentIndex+1) + " / " + currentTactic.graphs.length)
}

// function changing the currently displayed tactic
function changeTactic(tacticName){
	psgraph.graphs.forEach(function(entry){
        if (entry.name == tacticName){
            currentTactic = entry
        }
    })
	currentIndex = 0
	loadNewGraph(currentTactic.graphs[currentIndex])
    updateGraphNav()
}

// function switching the current graph to the previous in the current tactic
function previousSubGraph(){
    if(currentIndex > 0){
        currentIndex -= 1
        loadNewGraph(currentTactic.graphs[currentIndex])
        updateGraphNav()
    }
}

// function switching the current graph to the next in the current tactic
function nextSubGraph(){
    if(currentIndex < currentTactic.graphs.length-1){
        currentIndex += 1
        loadNewGraph(currentTactic.graphs[currentIndex])
        updateGraphNav()
    }
}

// function loading a psgraph
function loadPSGraph(p){
	psgraph = p
    
	var path = psgraph.current.slice(0)
	var pathString = path.reverse()[0]
	for(var i=1; i < path.length; i++){
		pathString += " > "+path[i]
	}
    d3.select("span#graphTactic").text(pathString)
    
	tacticList = []
    
	psgraph.graphs.forEach(function(entry){
        tacticList.push(entry.name)
        if (entry.name == psgraph.current[0]){
            currentTactic = entry
        }
    })
	currentIndex = psgraph.current_index
	loadNewGraph(currentTactic.graphs[currentIndex])
    
    updateGraphNav()
    
	var tacticSelection = d3.select("select#tacticList").selectAll("option").data(tacticList,function(d){return d})
	tacticSelection.attr("selected",null)
	tacticSelection.enter()
		.append("option")
		.attr("value",function(d){return d})
		.text(function(d){return d==psgraph.main?d+" - (root)":d})
	tacticSelection.attr("selected",function(d){return currentTactic.name == d?true:null})
	tacticSelection.exit().remove()
	d3.select("select#tacticList")
		.on("change",function(){
			changeTactic(d3.event.target.value)
		})
}

// function launching the overall visualisation
function visualiseProof(data,index){
    currentPSGraphIndex = (typeof index === 'undefined') ? 0 : index
    psgraphs = data
    if(currentPSGraphIndex == 0){
        d3.select("button#previousPSGraph").attr("disabled",true)
    }
    if(currentPSGraphIndex == psgraphs.length-1){
        d3.select("button#nextPSGraph").attr("disabled",true)
    }
    d3.select("span#vizIndices").text((currentPSGraphIndex+1) + " / " + psgraphs.length)
    loadPSGraph(psgraphs[currentPSGraphIndex])
}

// function to switch to the previous psgraph in the record array
function previousPSGraph(){
    if(currentPSGraphIndex > 0){
        d3.select("button#nextPSGraph").attr("disabled",null)
        currentPSGraphIndex -= 1
        if(currentPSGraphIndex == 0){
            d3.select("button#previousPSGraph").attr("disabled",true)
        }
        d3.select("span#vizIndices").text((currentPSGraphIndex+1) + " / " + psgraphs.length)
        loadPSGraph(psgraphs[currentPSGraphIndex])
    }
}

// function to switch to the next psgraph in the record array
function nextPSGraph(){
    if(currentPSGraphIndex < psgraphs.length-1){
        d3.select("button#previousPSGraph").attr("disabled",null)
        currentPSGraphIndex += 1
        if(currentPSGraphIndex == psgraphs.length-1){
            d3.select("button#nextPSGraph").attr("disabled",true)
        }
        d3.select("span#vizIndices").text((currentPSGraphIndex+1) + " / " + psgraphs.length)
        loadPSGraph(psgraphs[currentPSGraphIndex])
    }
}

// function to read a local file, launches data loaded callback when done
function loadLocal(evt){
    var reader = new FileReader();
    reader.onload = function(e){
        try{
            var data = JSON.parse(e.target.result)
            if(data.info.title && data.psgraphs){
                dataLoaded(null,data)
            } else {
                dataLoaded({status:0,statusText:"Bad data format."},null)
            }
        } catch(e) {
            dataLoaded({status:0,statusText:"Could not parse as Json."},null)
        }
    }
    reader.readAsText(evt.target.files[0])
}

// callback function when record has been loaded or if error occur
function dataLoaded(error, data) {
    if (error){
        d3.select("div#graphContent").style("display","none")
        var errorDiv = d3.select("div#graphError").style("visibility","visible").style("display",null)
        errorDiv.selectAll("h2").remove()
        errorDiv.selectAll("h3").remove()
        errorDiv.selectAll("input").remove()
        errorDiv.append("h2").text(error.status)
        errorDiv.append("h3").text(error.statusText)
        errorDiv.append("input")
            .attr("id","inputFile")
            .attr("type","file")
        document.getElementById('inputFile').addEventListener('change',loadLocal,false)
    } else {
        d3.select("div#graphError").style("display","none")
        d3.select("div#graphContent").style("visibility","visible").style("display",null)
        d3.select("span#proofTitle").text(data.info.title)
        if(data.info.author){ d3.select("span#proofAuthor").text("by "+data.info.author) }
        if(data.info.date){d3.select("span#proofDate").text("("+data.info.date+")")}
        visualiseProof(data.psgraphs,0)
    }
}

// code executed on script load
d3.json("ressources/record.json",dataLoaded,function(error){window.alert("Request : "+error.responseURL+"\nStatus : "+error.status+"\nMessage : "+error.statusText);console.log(error)})
/*if(file != ""){
} else {
    d3.select("div#content").style("display","none")
    d3.select("div#error").style("visibility","visible").style("display",null)
        .append("h2").text("No file specified")
    d3.select("div#error").append("input")
        .attr("id","inputFile")
        .attr("type","file")
        //.on("change",loadLocal)
    document.getElementById('inputFile').addEventListener('change',loadLocal,false)
}*/