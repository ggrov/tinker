(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *) 
(*  Title:      cinfo/htrace/rst_name.ML
    Author:     Lucas Dixon, University of Edinburgh
                lucas.dixon@ed.ac.uk
    created:    30 Jun 2005
*)
(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *) 
(*  DESCRIPTION:

    Little library for more easily naming reasoning states 

*)
(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *) 
signature RST_NAME =
sig
type T
val str : string -> T
val pretty : Pretty.T -> T
val block : T list -> T
val chunks : T list -> T
val append_block : T -> T -> T
val prepend_block : T -> T -> T
val append_chunks : T -> T -> T 
val prepend_chunks : T -> T -> T 
(*val dmeth : DMethod.T -> T
val by_dmeth : DMethod.T -> T
*)
val dtac : DTac.T -> T
val by_dtac : DTac.T -> T
val term : Term.term -> T
val named_term : string -> Term.term -> T
val f : (RState.T -> Pretty.T) -> T
val apply : T -> RState.T -> Pretty.T


end;

structure RstName : RST_NAME =
struct
type T = RState.T -> Pretty.T

(* break up words *)
fun pretty_words s = 
    Pretty.block (map Pretty.str 
                      (Library.separate " " (space_explode " " s)));

(* note cunning trick to evalute pretty words directly but still
return a function. The idea is to use this function when writing
techniques as values, thus the prettifying of words is directly
evaluated at compile time instead of runtime. *)
fun str s = let val p = pretty_words s in (fn _ => p) end;
fun pretty p = K p;

fun block dl rst = Pretty.block (map (fn f => f rst) dl);
fun chunks dl rst = Pretty.chunks (map (fn f => f rst) dl);

fun append_block d' d rst = Pretty.block [d rst, d' rst];
fun prepend_block d' d rst = Pretty.block [d' rst, d rst];
fun append_chunks d' d rst = Pretty.block [d rst, d' rst];
fun prepend_chunks d' d rst = Pretty.block [d' rst, d rst];

(* prettying methods *)
(*fun dmeth dmeth rst =
    DMethod.pretty_of dmeth ((Proof.context_of o PPlan.top_pst_of o 
                              RState.get_pplan) rst);

fun by_dmeth m rst = 
    Pretty.block [Pretty.str " by ",
                  Pretty.enclose "(" ")" 
                                 [dmeth m rst]];
*)
fun dtac dtac rst =
    DTac.pretty dtac (RState.get_ctxt rst);

fun by_dtac dtac rst = 
    Pretty.block [Pretty.str " by ",
                  Pretty.enclose "(" ")" 
                                 [DTac.pretty dtac (RState.get_ctxt rst)]];
(* pretty function for the term in context of rst *)
fun term t rst = PPlan.pretty_term (RState.get_pplan rst) t;

fun named_term s t rst =
    Pretty.block [pretty_words s,
                  Pretty.quote (term t rst)];

val f = I;

fun apply pf rst = pf rst;


end;
