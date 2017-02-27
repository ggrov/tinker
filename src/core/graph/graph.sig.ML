signature GRAPH_SHARING = 
sig
  type T
  structure data : GRAPH_DATA_SHARING
end

signature GRAPH  =
sig
  structure graph_data : GRAPH_DATA

  type T

  structure Sharing : GRAPH_SHARING
end