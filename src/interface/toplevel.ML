
(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *) 
(*  Title:      ./interface/toplevel.ML
    Author:     Lucas Dixon, University of Edinburgh
                lucasd@dai.ed.ac.uk
*)
(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *) 
(*  DESCRIPTION:

   top level ML functions to work with proof planning in IsaPlanner

*)
(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *) 

(* set wide margins *)
val _ = Pretty.setmargin 200;

(* apply a search technique, giving timings and stats for search for 
   the first result. *)
fun pp_srch srch r goalstr = 
    let 
      val res_seq = srch (PPInterface.prep_rst r goalstr)
                    
      fun rst_result NONE = "No proof found."
        | rst_result (SOME (rst,_)) = Pretty.string_of 
                                        (PPInterface.pretty_rst rst)

      val t = startTiming()
      val result = (Seq.pull res_seq)
      val infostr = (endTiming(t))
    in
      (writeln (infostr ^ (rst_result result)); res_seq)
    end;

(* proof planning result state printer *)
fun ppr sq = 
    case Seq.pull sq of 
      NONE => (writeln "\nNo (more?) solutions\n"; Seq.empty)
    | SOME (st,sq2) => (Pretty.writeln (PPInterface.pretty_rst st); sq2);

(* proof plan depth first, giving summary stats as output *)
fun pp_dfs_stats r goalstr = 
    PPInterface.pp_rst_stats PPInterface.depth_fs r goalstr;

(* basic proof palnning using depth first search *)
val pp_dfs = pp_srch PPInterface.depth_fs;

(* exploratory Interactive Proof Planning, with debugging-enabled search *)
val ipp_rst = PPInterface.ipp_rst;
val unf  = Seq.list_of o RState.unfold;

(* debug proof planning exception by going to last OK state *)
fun ipp_debug_chk () = (ipp_rst o Library.the o RState.get_prev) (PPInterface.dbg_rst());
val dbg_rst = PPInterface.dbg_rst;
fun print_last_rst () = 
    (Pretty.writeln o PPInterface.pretty_rst) (PPInterface.dbg_rst());
val print_rst = Pretty.writeln o PPInterface.pretty_rst;

(* interactive proof planning *)
fun ipp r s = ipp_rst (PPInterface.prep_rst r s);

(* interactive proof planning with stacked search *)
(*fun ipp_st topstrat r s = PPInterface.ipp_st_rst topstrat (PPInterface.prep_rst r s);*)
fun ipp_st initstrat r s = PPInterface.ipp_st_rst initstrat (PPInterface.prep_rst r s);

(* the main encoded techniques ... *)
(* val my_apply_indsimp_techn = ApplyRTechn.ind_then_simp;
val sinbad_techn = IndAndSimpIsarRTechn.my_simp_and_induct_techn; *)
val rippling = RippleRTechn.induct_and_ripple; 
val bf_rippling = Bf_Rippling_dsum.induct_ripple_conj Bf_Rippling_dsum.basic_bf_steps;

val bestfs = MSearch.bestfs (Bf_Rippling_dsum.compare_rsts);


(* limit re-writing of the simplifier *)
(* Note: Requires my Simplifier Hack, see: IsaPlanner/mods/ *)
(* 
MetaSimplifier.limit_rw := true;
MetaSimplifier.rw_max_c := 1000;
*)


(* exmaple to get Prolog from proof plan: 
use_thy "theories/ijcar/IJCAR";
Pretty.writeln (PPInterface.polog_of_rst (ipp rippling "a + b = b + a"));

*)
