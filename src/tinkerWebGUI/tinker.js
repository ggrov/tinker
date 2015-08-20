function dataLoaded(error, data) {
    if (error){
        d3.select("div#content").style("display","none")
        var errorDiv = d3.select("div#error").style("visibility","visible")
        errorDiv.append("h2").text(error.status)
        errorDiv.append("h3").text(error.statusText)
    } else {
        d3.select("div#error").style("display","none")
        d3.select("div#content").style("visibility","visible")
        d3.select("span#proofTitle").text(data.info.title)
        if(data.info.author){ d3.select("span#proofAuthor").text("by "+data.info.author) }
        if(data.info.date){d3.select("span#proofDate").text("("+data.info.date+")")}
        visualiseProof(data.psgraphs,grIndex)
    }
}

var psgraphs,
    currentPSGraphIndex

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

var file = window.location.search ? window.location.search.split('?')[1].split('/')[0] : ""
var grIndex = window.location.hash ? parseInt(window.location.hash.split('#')[1].split('/')[0]) : 0

if(file != ""){
    d3.json("records/"+file+".json",dataLoaded,function(error){window.alert("Request : "+error.responseURL+"\nStatus : "+error.status+"\nMessage : "+error.statusText);console.log(error)})
} else {
    d3.select("div#content").style("display","none")
    d3.select("div#error").style("visibility","visible")
        .append("h2").text("No file specified")
}