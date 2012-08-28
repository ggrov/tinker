

structure Strategy_DotStyle : DOT_STYLE =
struct
  structure Graph = Strategy_Theory.Graph
  fun style_for_ivertex_data x = "[style=filled,fillcolor=white,fontcolor=black,shape=circle]"
end;

structure Strategy_OutputGraphDot = OutputGraphDot(structure DotStyle = Strategy_DotStyle)
