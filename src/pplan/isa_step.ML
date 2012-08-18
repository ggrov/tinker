(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *) 
(*  Title:      isa_step.ML
    Author:     Lucas Dixon, University of Edinburgh
                lucas.dixon@ed.ac.uk
    Updated:    March 2007 - Lucas Dixon
*)
(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *) 
(*  
    Applying Isabelle Tatics but keeping a record of the instantiations
    to meta-variables. 
*)
(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *) 

signature ISASTEP 
= sig

val add_openvars_sg_to_thm : ((Term.indexname * Term.sort) list 
                          * (Term.indexname * Term.typ) list) 
                         -> Thm.thm -> Thm.thm 

val strip_insts : Trm.TrmParams.T (* lift new vars over these *)
                  -> ((Term.indexname * Term.sort) list  (* open vars *)
                      * (Term.indexname * Term.typ) list) 
                  -> Thm.thm (* init instenv, new thm *)
                  -> (InstEnv.T * Term.term list) (* new instenv and subgoals *)

val apply_winst 
    : ((Term.indexname * Term.sort) list 
                     * (Term.indexname * Term.typ) list) 
      -> Tactical.tactic
      -> (Context.theory * InstEnv.T * Trm.TrmParams.T)
      -> Thm.thm 
      -> (InstEnv.T * Term.term list) Seq.seq  (* instenv and subgoals *)

end;


structure IsaStep 
= struct

local 
val thry = (@{theory "Pure"});
val inittyp = Thm.ctyp_of thry (TVar( ("'a", 0), []));
val totyp = Thm.ctyp_of thry (Type("prop", []));
val initvar = Thm.cterm_of thry (Var( ("x",0), (Type("prop", []))));
val tovar = Thm.cterm_of thry (Free("x", (Type("prop", []))));
in
(* trivial true theorem without vars, to remove the fake subgoal that
we introduced to hold var instantiations *)
val true_triviality =
    (@{thm "Pure.reflexive"})
      |>  Thm.instantiate ([(inittyp, totyp)],[])
      |>  Thm.instantiate ([],[(initvar, tovar)]);
end;

(* make subgoal to hold var instantiations *)
fun mk_mvars_holder vs =
    (Term.list_comb (Free (":mvarh", (map snd vs) ---> Type("prop", [])),
                     map Term.Var vs));

fun mk_mtvars_holder tvs =
    let val typholder = (map TVar tvs) ---> Type("prop", []) in 
      (Term.$ ( Free (":mtvarh_f", typholder --> Type("prop", [])),
                ( Free (":mtvarh_arg", typholder))))
    end;

(* add in a subgoal to hold var instantiations *)
fun add_openvars_sg_to_thm (opentvs,openvs) th = 
    let 
      val thry = Thm.theory_of_thm th;
      val cvs = Thm.cterm_of thry (mk_mvars_holder openvs);
      val ctvs = Thm.cterm_of thry (mk_mtvars_holder opentvs);
    in (th |> Thm.implies_intr cvs
           |> Thm.implies_intr ctvs
           |> Drule.rotate_prems 2) 
    end;

(* 
fun remove_open_sg_from_thm (opentvs,openvs) th = 
    th |> Drule.rotate_prems ~2
       |> Thm.forall_intr 
*)

(* mk_thin thry vtab ct cvs *)

exception thm_tricks_exp of string;

fun pull_term_insts t = 
    (case Term.strip_comb t 
      of (v as (Free(":mvarh", _)), insts) => 
         (v,insts)
       | _ => raise thm_tricks_exp "pull_term_insts: bad term");

fun pull_typ_insts (Term.$ (v as Free(":mtvarh_f", _), 
                            (Free (":mtvarh_arg", typholder)))) = 
    (v,Term.binder_types typholder)
  | pull_typ_insts _ = raise thm_tricks_exp "pull_typ_insts: bad term";

(* the last subgoal is assumed to be the meta variable holder goal *)
(*  FIXME: what about flexflexes? *)
fun strip_insts params (tvs, vs) th = 
    let 
      val ffs =
          case Thm.tpairs_of th 
           of [] => true 
            | _ => raise thm_tricks_exp "strip_insts cannot have flex-flex pairs in theorem - solve them first?";
      
      val th2 = Drule.rotate_prems (~2) th;
      
      val prop = Thm.prop_of th2

      val (tyinstsubgoal, instsgoal, subgoals) = 
          case Logic.strip_imp_prems prop of 
            (h1::h2::t) => (h1,h2,t)
          | _ => raise thm_tricks_exp "strip_insts: theorem has lost it's variable holding subgoals";

      val (v, insts) = pull_term_insts instsgoal;
      val (tv, tyinsts) = pull_typ_insts tyinstsubgoal;

      val instenv = 
          (InstEnv.init (ProofContext.init_global (Thm.theory_of_thm th2)))
            |> (fold InstEnv.add_var_inst
                     (map (fn ((n,ty),i) => (n,(ty,i))) (vs ~~ insts)))
            |> (fold InstEnv.add_tvar_inst
                     (map (fn ((n,srt),i) => (n,(srt,i))) (tvs ~~ tyinsts)));

      val rename_env = 
          InstEnv.mk_invert_var_renamings (TVar.NSet.of_list (map fst tvs), 
                                           Var.NSet.of_list (map fst vs)) instenv;
      val subgoals2 = map (InstEnv.inst_trm rename_env) subgoals;

      (* lift new vars? no. - we'd need to lift the instenv also. 
      val th_vtab = fold (Trm.merge_joint_vtabs o Trm.vtab_of) 
                         subgoals2
                         Trm.empty_vtab;
      val plist = Trm.TrmParams.get_plist params;

       val new_var_typs = (Trm.difference_vtab th_vtab vtab)
                           |> Trm.lift_vtab_typs plist;

      val subgoals3 = map (Trm.lift_vars (plist, new_var_typs))
                          subgoals2
      *) 
    in (InstEnv.correct_var_renamings rename_env instenv, subgoals2) end;

(*  
we can give back the theorem within the original name space...
This will allow it's flexes to be used.

      val thry = (Thm.theory_of_thm th2);
      val vabs = map (fn ((n,i),ty) => (n,ty)) vs;
      val tvabs = map (fn ((n,i),srt) => (n,srt)) tvs;

       th2 
         |> InstEnv.inst_thm rename_env
         |> forall_intr_list [(Thm.cterm_of thry v)]
         |> Thm.forall_elim 
            (Thm.cterm_of thry (list_abs (tvabs,Thm.prop_of true_triviality)))
         |> Thm.forall_elim 
            (Thm.cterm_of thry (list_abs (vabs,Thm.prop_of true_triviality)))
         |> Seq.hd o rtac true_triviality 1
*)

(* apply dtactic (assumed to be to sugoal 1), and record
instantiations using a cleaver trick of extra assumptions to hold the
extra variable. *)
fun apply_winst openvars tac (thy,ienv,params) th = 
    let val prep_th = add_openvars_sg_to_thm openvars th;
    in 
      Seq.map (strip_insts params openvars)
              (tac (thy,ienv,params) prep_th)
    end;


end;
