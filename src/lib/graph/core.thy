theory core
imports "../isalib"
begin

(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *)
(*                         Compile quantomatic core                        *)
(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *)

(* 
 * Utility Code
 *)

(* IO Utils *)
ML_file "io/input.ML"
ML_file "io/output.ML"
ML_file "io/json_io.ML"
ML_file "io/file_io.ML"


(*
 * Names
 *)
ML_file "names.ML" (* defines basic names used in Quantomatic *)


(*
 * Expressions for use in graph component data
 *)
ML_file "expressions/lex.ML"
ML_file "expressions/coeff.ML"
ML_file "expressions/matrix.ML"
ML_file "expressions/expr.ML"
ML_file "expressions/linrat_expr.ML"
ML_file "expressions/linrat_angle_expr.ML"
ML_file "expressions/semiring.ML"
ML_file "expressions/tensor.ML"
ML_file "expressions/linrat_angle_matcher.ML"
ML_file "expressions/linrat_matcher.ML"

ML_file "expressions/alg.ML" (* algebraic expression utils *)

(* I/O *)
ML_file "io/linrat_json.ML"


(*
 * Graphs
 *)

(* arity of vertices (in,out,undir) *)
ML_file "graph/arity.ML"
(* neighbourhood data for non-commutative vertices *)
ML_file "graph/nhd.ML"


ML_file "graph/graph_data.ML"
ML_file "graph/ograph.sig.ML"
ML_file "graph/bang_graph.sig.ML"
ML_file "graph/bang_graph.ML"

ML_file "graph/graph_annotations.ML" (* graph annotations *)

(* I/O *)
ML_file "io/graph_json.ML"
ML_file "io/graph_annotations_json.ML"
ML_file "io/graph_dot_output.ML"
end
