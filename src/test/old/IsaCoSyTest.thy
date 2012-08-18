header{* Running, testing and debugging IsaCoSy *}
theory IsaCoSyTest
imports "IsaP"
begin
ML{*

*}

datatype mynat = ZZero | SSuc mynat

fun pplus where 
  "pplus ZZero x = x"
| "pplus (SSuc x) y = SSuc(pplus x y)"

 
lemmas plus_rules = pplus.simps
lemmas inject[impwrule] = mynat.inject
lemmas wrules[wrule] = plus_rules

(*
fun dummy where
"dummy ZZero x = True"
  | "dummy (SSuc x) y = (case y of ZZero => True | (SSuc z) => False)"
lemmas dummyrules = dummy.simps
lemmas wrules2[wrule] = dummyrules
*)
ML {*
val (Const(pplus_const,pplus_ty)) = @{term "pplus"}

  (* set constraint params *)
  val cparams0 = 
      ConstraintParams.empty 
        |> ThyConstraintParams.add_eq @{context}
        |> ThyConstraintParams.add_datatype' @{context} @{typ "mynat"}
        |> ((ConstraintParams.add_consts o map Term.dest_Const)
            [@{term "pplus"}])
        |> ConstraintParams.add_thms @{context} 
            (@{thms "plus_rules"})


  val (init_ctxt, cparams) = 
  ConstraintParams.add_ac_properties_of_const @{context}
                  (pplus_const,pplus_ty) @{thms "plus_rules"} cparams0;

  ConstraintParams.print init_ctxt cparams;
*}


ML {*
val thy_constraints = (Constraints.init init_ctxt cparams);
Constraints.print init_ctxt thy_constraints;
val top_term = Thm.term_of @{cpat "op = :: ?'a => ?'a => bool"};
val top_const = (Constant.mk (fst (Term.dest_Const top_term)));


*}

ML{*
val timer = Timer.startCPUTimer();
val (nw_cparams, nw_ctxt) = SynthInterface.thm_synth
  SynthInterface.rippling_prover 
  SynthInterface.quickcheck 
  SynthInterface.try_reprove_config 
  SynthInterface.var_allowed_in_lhs
  {max_size = 11,min_size = 3, max_vars = 3, max_nesting= SOME 2} 
  (Constant.mk "HOL.eq") (cparams0,@{context}); 
val end_time = Timer.checkCPUTimer timer;


map (Trm.print nw_ctxt) (SynthOutput.get_all (SynthOutput.Ctxt.get nw_ctxt));

*}

ML{*

val num_conjs = DB_SynthOutput.get_tot_synthterms (DB_SynthOutput.Ctxt.get nw_ctxt);
writeln "Theorems:";
val thms = SynthOutput.get_thms (SynthOutput.Ctxt.get nw_ctxt);
map (fn (_,thm) => Trm.print nw_ctxt (Thm.concl_of thm)) thms;
writeln "Open Conjectures:";
val open_conjs = SynthOutput.get_conjs (SynthOutput.Ctxt.get nw_ctxt);
map (Trm.print nw_ctxt) open_conjs;



*}
ML{*
open InstEnv;
val (s,i) = InstEnv.new_uninst_var (Var.mk "x", @{typ "mynat"}) (InstEnv.init nw_ctxt);
*}
ML{*

val all_terms = (SynthOutput.get_all (SynthOutput.Ctxt.get nw_ctxt));
val all_conjs = filter (SynthPrfTools.counter_ex_check nw_ctxt) all_terms;
*}
ML{*
val open_conjs = SynthOutput.get_conjs (SynthOutput.Ctxt.get nw_ctxt);
map (Trm.print nw_ctxt) open_conjs;
val thms =  SynthOutput.get_thms (SynthOutput.Ctxt.get nw_ctxt);
ConstraintParams.print nw_ctxt nw_cparams;
val num_conjs = SynthOutput.get_tot_synthterms (SynthOutput.Ctxt.get nw_ctxt);

map (Trm.print nw_ctxt) all_conjs;
*}


ML{*
val t1 = Thm.term_of @{cpat "pplus (pplus ?a ?b) ?c = pplus (pplus ?c ?a) ?b"};
val t1' = @{term "pplus (pplus a b) c = pplus (pplus c a) b"};
val t0 = Thm.term_of @{cpat "pplus (pplus ?a ?a) ?b = pplus (pplus ?b ?a) ?a"};
val t0' =  @{term "pplus (pplus a a) b = pplus (pplus b a) a"};

val match1 = MyUnify.match [(t1,t1')] (InstEnv.init @{context});
val match0 = MyUnify.match [(t0,t1')] (InstEnv.init @{context}); 

Seq.pull (MyUnify.unifiers ((InstEnv.init @{context}), [(t1,t0)]));
Seq.pull (MyUnify.unifiers ((InstEnv.init @{context}), [(t0,t1)]));
*}
ML{*
open Net;
Net.delete_term;
*}
ML{*
ConstraintParams.termrw_of_thm;
val t1 = @{term "pplus (pplus x y) z"};
val t2 = @{term  "pplus x (pplus y z)"};

val t3 =  @{term "pplus x y"};
val t4 =  @{term "pplus y x"};
val Const(pplus_n,pplus_ty) = @{term "pplus"} 
val Const(ssuc_n,_) = @{term "SSuc"} 
val Const(zzero_n,_) = @{term "ZZero"} ;

fun prec t = case t of 
  Const(pplus_n,_) => 3
  | Const(ssuc_n,_) => 2
  | Const(zzero_n,_) => 1
  | _ => 0;

DB_Termination.lpo prec (t1,t2);
DB_Termination.lpo prec (t2,t1);
DB_Termination.lpo prec (t3,t4);
DB_Termination.lpo prec (t4,t3);

*}

ML{*
val SOME com = SchemeBasedSynth.commute_template ("IsaCoSyTest.dummy",@{typ "mynat => mynat => bool"});
val SOME asc = SchemeBasedSynth.assoc_template ("IsaCoSyTest.dummy",@{typ "mynat => mynat => bool"});

val thrms = SchemeBasedSynth.synth_ac_thrms @{theory} ("IsaCoSyTest.dummy",@{typ "mynat => mynat => bool"}) (map Thm.concl_of @{thms "dummyrules"});

map (Trm.print @{context} o Thm.concl_of) thrms

*}

ML{*
val SOME com = SchemeBasedSynth.commute_template ("IsaCoSyTest.pplus",@{typ "mynat => mynat => mynat"});
val SOME asc = SchemeBasedSynth.assoc_template ("IsaCoSyTest.pplus",@{typ "mynat => mynat => mynat"});

val thrms = SchemeBasedSynth.synth_ac_thrms @{theory} ("IsaCoSyTest.pplus",@{typ "mynat => mynat => mynat"}) (map Thm.concl_of @{thms "rules"});

map (Trm.print @{context} o Thm.concl_of) thrms
 
*}



 
ML{*
val ((thy_constraints',thy'), (* updated constraints and theory *) 
     (conjs,thms))
    = PolyML.exception_trace (fn () => 
    ConstrSynthesis.synthesise_terms 
       top_const (* top constant *)
       ConstrSynthesis.VarAllowed.is_hole_in_lhs (* where are free vars allowed *)
       (* ConstrSynthesis.VarAllowed.always_yes  *)
       (3,7) (* min and max size of synthesised terms *)
       3 (* max vars *)
       @{theory} (* initial theory *)
       thy_constraints (* initial theory constraints *) )
       ;
*}


ML{*
  Pretty.writeln (Pretty.str "---- Thms: ---- ");
  val _ = map (Trm.print @{context} o fst) thms;
  Pretty.writeln (Pretty.str "---- Conjs: ---- ");
  val _ = map (Trm.print @{context} o fst) conjs;
  Pretty.writeln (Pretty.str "---------------- ");
*}



 

ML{*
val t = @{term "f(a,a,b)"};
val t2 = @{term "f(a,b,b)"};
val x = Term_Ord.term_ord(t,t2);

val t3 = @{term "f(a,a,b)"};
(*
val (nm,ty) = Term.dest_Free t;
val (tnm,sort) = Term.dest_TFree ty; 
*)
*}
ML{*
fun mkfree typ (t', paramtab)= 
    let 
      val (fresh_nm,ptab) = Trm.TrmParams.add1 ("x",typ) paramtab
    in (t'$Free(fresh_nm,typ), ptab) end;

(* Takes a constant and builds a term with the constant applied
   to appropriate number of arguments as free-variables. *)
fun build_simple_constructor_term t =
    case t of 
      Const(_,ty) => 
      let 
        val (argtyps,_) = Term.strip_type ty       
      in 
        fold mkfree argtyps (t,Trm.params_of t) 
      end
    | _ => raise ERROR "build_simpl_contructor_term: Expecting to get a constant.";

(*Term.term list => Term.typ * Term.typ list => Context => string => Term.term list *)
(* rec_dtype_constrs : a list of terms, of Consts*)
fun gen_lhs rec_dtype_constructors (rec_arg_type, other_arg_types) ctxt fun_nm = 
    let 
      (* We assume we're given a list of constants (Term.Const), which represent
         the constructors of the datatype we're supposed to recurse over *)
      val constructor_trms = 
          (map build_simple_constructor_term rec_dtype_constructors)
            |> map fst
      val ienv0 = InstEnv.init (Context.theory_of ctxt)
      val (ty_varnm, ienv) = InstEnv.new_uninst_tvar (("a",0),[]) ienv0
      val fun_const = 
          Const(fun_nm, rec_arg_type::other_arg_types ---> TVar(ty_varnm,[]))
      val cases = map (fn constr => fun_const$constr) constructor_trms
    in
      map (fn t => fold mkfree other_arg_types (t,Trm.params_of t)) cases 
    end;

*}

ML{*
fun equal_size_eq z =
    let 
      fun size_of_trm t =
          case t of 
            t1$t2 => (size_of_trm t1) + (size_of_trm t2)
          | Term.Abs(_,_,body) => 1 + size_of_trm body
          | _ => 1
    in
       size_of_trm (Zipper.trm (Subst.move_to_lhs_of_eq z)) = 
       size_of_trm (Zipper.trm (Subst.move_to_rhs_of_eq z))
    end
    (* if it isn't an equation *)
    (* what I want to handle is a Subst.LData.bad_term_exp, but it's hidden 
       in the signature, so you can't *)
    handle _ => false;

(* Commutes the arguments if this is an equation *)
fun swap_eq z =
    case Zipper.trm z of
      (Const("op =",ty)$arg1$arg2) =>
       Const("op =",ty)$arg2$arg1
    | t => t; 

val t = @{term "f a = f b"};
val dummy = @{term "f x"};
val z = Zipper.mktop t;
val eq = equal_size_eq z
val dummy_eq = equal_size_eq (Zipper.mktop dummy);

val swap = swap_eq z;
val dummy_swap = swap_eq (Zipper.mktop dummy);
(* Term_Ord.term_ord (t2,t3); *)

*}


ML{*
(*open Synthesis;
fun mk_strms top_cinfo max_size max_vars thy =
  let 
  val top_cnstrs = ConstInfo.get_constrTab top_cinfo

			val (init_trm, init_holes, ienv, allowed_tab1) = 		
					mk_new_term_bit top_cinfo (HoleTab.empty) (InstEnv.init thy)
			val hole_nms_typs = map (fn (nm,ty) => (Hole.mk nm, ty)) init_holes
      val hole_nms = map fst hole_nms_typs;

			(* Debugging: make sure names here are different from the constant-info *)
			val init_constr_tab = ConstrTab.useup_names (ConstrTab.get_nameset top_cnstrs) 
																									ConstrTab.empty
			val constr_renamings = (rename_constraints top_cnstrs init_constr_tab)
														 |> ConstraintName.nmap_of_renaming
				
			val constr_dep_tab1 = 
					init_constr_dep_tab constr_renamings top_cnstrs

			(* Add renamed constraints to the constraint-table and to the table 
         of constraints for each hole *)
			val (hole_constr_tab, constr_tab, allowed_tab, constr_dep_tab) = 
					List.foldl (attach_constr top_cnstrs constr_renamings (map fst hole_nms_typs))
								(HoleTab.empty, init_constr_tab, allowed_tab1, constr_dep_tab1) 
								(map snd (ConstInfo.get_start_constrs top_cinfo))
			
			val commute_opt = ConstInfo.get_commute_opt top_cinfo
  in 
	map (fn holesizes =>
	Sterm {term = init_trm,
	ienv = ienv,
	allowedTab = allowed_tab,
	constrTab = constr_tab,
	holeConstrs = hole_constr_tab,
	constrDepTab = constr_dep_tab,
	holes_agenda = hole_nms,
  hole_sizes = holesizes,
	max_vars = max_vars})
	((hole_size_combos commute_opt hole_nms (max_size -1))
  |> map (fn l => (fold Hole.NTab.ins l Hole.NTab.empty)))
	end;
*)
*}

ML{*
use_thy "src/benchmarks/synth_theories/N_plus_mult";
val thy0 = theory "N_plus_mult";
val (cs, thy) = ConstInfo.mk_const_infos_ac thy0;
*}

ML{*

fun weight_of constr_tab (Const(c1,_)) =
  if c1 = "Groups.plus_class.plus" then 2 else 
  if c1 = "Grounp.times_class.times" then 3
  else ~1
  | weight_of _ _ = ~1;

val ctxt = ProofContext.set_mode (ProofContext.mode_schematic) @{context};
val lhs = Syntax.read_term ctxt "(Suc x) + a" 
val rhs = Syntax.read_term ctxt "Suc(x + y)"
*}
ML{*
val valid = PolyML.exception_trace (fn () => 
  Term_Ord.term_lpo (weight_of cs) (lhs,rhs));

(*val consts = map snd (ConstInfo.ConstInfoTab.list_of cs);
map (ConstInfo.print_constinfo ctxt) consts;*)
*}


ML{*

val top_const = (ConstName.mk "op =");
val top_cinfo = the (ConstInfo.lookup_const cs top_const);
val strms =  mk_strms top_cinfo 6 2 thy;
*}


ML {*
use_thy "src/benchmarks/synth_theories/Tree_size_height";
val thy0 = theory "Tree_size_height";
val (cs, thy) = ConstInfo.mk_const_infos_ac thy0;
*}

ML{* 
Synthesis.synth_w_stats (3, 8) 2 thy cs;
*}

ML{*use "src/synthesis/synthesise2.ML" *}

ML{* 
  ;
*}
ML{* 
  val terms = 
  Synthesis2.synth_w_stats 5 2 thy0 ["Tree_size_height.max"] cs;
*}

ML{* 
  val terms = 
  Synthesis.synthesise_f_terms "Tree_size_height.nodes" (2, 5) 2 thy cs;
*}
ML{*
val ctxt = ProofContext.init thy;
  PrintMode.setmp []
  (fn () => 
  Pretty.writeln (Pretty.chunks( 
  (Pretty.str "Synthesised Terms: ") :: (map (fn trm => Trm.pretty ctxt trm) terms)))) ();

*}

ML{*
SStrName.NTab.fold;
foldl;
*}
ML {*
use_thy "src/benchmarks/synth_theories/Tree_size_height";
val thy0 = theory "Tree_size_height";

(* Create initial constant-informations,
   including looking for AC-properties *)
val (cs, thy) = ConstInfo.mk_const_infos_ac thy0;

*}
ML{* 
Synthesis.synth_w_stats (3, 8) 2 thy cs;
*}
end;