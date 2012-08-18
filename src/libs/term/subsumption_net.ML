(* FIXME: hacky hacky; and only used by synthesis *)
(* And it does the wrong thing too! If it adds a less general term
  first, it thinks this subsumes all more general terms considered later. Should
  be able to replace the term in the subsumption net, if the new term is more general.

I think it should do matching instead of unification, and fix the Vars in the in-term (replacing them by Frees) and match (not unify) against what's in the Net (which should have Vars).
*)
signature SUBSUMPTION_NET = 
sig
  (* represents a set of terms with quick additions and checking functions *)
  type T = Term.term Net.net;
  val empty : T;
  val add_term : Proof.context -> term -> term Net.net -> Trm.T Net.net


(* Proof.context -> Term.term -> T
      -> bool (* true if added (i.e. term wasn't there before) *)
         * T (* new net *)
*)
end;

structure SubsumptionNet : SUBSUMPTION_NET = 
struct

type T = Term.term Net.net;

val empty = Net.empty;

val freevars_alpha_conv = uncurry Trm.trm_name_eq;

fun varify_typ (*tyvtab*) ty = 
    Trm.map_typ_tfrees 
      (fn ((nm,sort), typ) => Trm.mk_tvar(Trm.var_of_free_name nm, sort)) ty

fun add_term ctxt tin net = 
    let 
      (* This is the term that gets put in the net, with Vars not Frees.
       Do we need to beta-eta contract the in-term before unification check?*)
      val t_varified = tin |> Envir.beta_eta_contract 
                       |> Trm.change_frees_to_fresh_vars
                       |> Trm.map_trm_types varify_typ
      (* Fix the vars, when we match against net-terms.*)
      val t_fixed = Trm.change_vars_to_fresh_frees tin;

      val net_ts =  Net.unify_term net tin; 
        (*  Net.match_term net t_fixed; *)

      (* This is wrong: should use matching. *)
      (*fun subsumed_by_nettrm net_t =
         (* case Seq.pull (MyUnify.unifiers (InstEnv.init ctxt, [(net_t,tin)])) of *)
          case (MyUnify.match [(net_t, t_fixed)]) (InstEnv.init ctxt) of
            SOME _ => true
          | NONE => (* Need to check if tin subsumes the net_term. *)
            (case (MyUnify.match [(t_varified, Trm.change_vars_to_fresh_frees net_t)]
                    (InstEnv.init ctxt)) of
               SOME => false, rm_net_term
             |_ NONE => false;) *)

      fun update_subsumption_net net_t (can_add_nwt, net) =
          if can_add_nwt then
            case (MyUnify.match [(net_t, t_fixed)]) (InstEnv.init ctxt) of
              SOME _ => (false, net)
            | NONE => (* Need to check if tin subsumes the net_term. *)
              (case (MyUnify.match [(t_varified, Trm.change_vars_to_fresh_frees net_t)]
                    (InstEnv.init ctxt)) of
                 SOME _ => (true, Net.delete_term freevars_alpha_conv (net_t,net_t) net)
               | NONE => (can_add_nwt, net)
              )
          else (can_add_nwt, net) (* It's already subsumed by something in net.*)
     
      val (unsubsumed, net') = fold update_subsumption_net net_ts (true,net);
    in
      if unsubsumed then 
        Net.insert_term freevars_alpha_conv (t_varified,t_varified) net'
      else net
    end

end;
