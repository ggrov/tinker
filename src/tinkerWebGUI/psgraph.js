var psgraph,
	currentTactic,
	currentIndex,
	tacticList;

function displayGraph(tactic,index){
	 psgraph.graphs.forEach(function(entry){
        if (entry.name == tactic){
            loadNewGraph(entry.graphs[index])
        }
    })
}

function changeTactic(tactic){
	currentTactic = tactic
	currentIndex = 0
	displayGraph(currentTactic,currentIndex)
}

function loadPSGraph(p){
	psgraph = p
	var path = psgraph.current.slice(0)
	var pathString = path.reverse()[0]
	for(var i=1; i < path.length; i++){
		pathString += " > "+path[i]
	}
    d3.select("span#graphTactic").text(pathString)
	tacticList = []
	currentTactic = psgraph.current[0]
	currentIndex = psgraph.current_index
	displayGraph(currentTactic,currentIndex)
	
	psgraph.graphs.forEach(function(entry){
		tacticList.push(entry.name)
	})
	var tacticSelection = d3.select("select#tacticList").selectAll("option").data(tacticList,function(d){return d})
	tacticSelection.attr("selected",null)
	tacticSelection.enter()
		.append("option")
		.attr("value",function(d){return d})
		.text(function(d){return d==psgraph.main?d+" - (root)":d})
	tacticSelection.attr("selected",function(d){return currentTactic == d?true:null})
	tacticSelection.exit().remove()
	d3.select("select#tacticList")
		.on("change",function(){
			changeTactic(d3.event.target.value)
		})
}