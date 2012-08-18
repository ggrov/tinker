(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *) 
(*  Title:      gproof/prf/lifting.ML
    Author:     Lucas Dixon, University of Edinburgh
                lucas.dixon@ed.ac.uk
*)
(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *) 
(*  
    Lifting of variables over paramers. 

    lift parameter x : Tx 
    over parameters a : Ta and b : Tb and ...
    creates a fresh variable ?X of type Ta -> Tb -> ... -> Tx
   
    lifting a term changes the lifted parameters to new fresh
    variables applied the parameters lifted over.
*)
(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *) 

signature LIFTING 
= sig

  (* a lifting of one set of parameters over another changes the
  lifted params to vars where each new var takes each param lifted
  over as an argument. *)
  type lifting 

  (* change params to vars *)
  val empty : lifting

  val mk : Trm.TrmParams.T (* lift over these things *)
        -> Trm.TrmParams.T (* making these params into vars *)
        -> InstEnv.T (* avoiding clashes with the existing var table *)
        -> (lifting * InstEnv.T) (* lifting and new ienv *)

  val lift : lifting -> Trm.T -> Trm.T

  (* internal *)
  val dest_lifting : 
      lifting -> (Trm.Free.name * Trm.typ) list (* lift over these *)
                 (* making these new vars *)
                  * (Var.name * Trm.typ) Trm.TrmParams.NTab.T; 

  (* pretty printing *)
  val pretty : Proof.context -> lifting -> Pretty.T
  val print : Proof.context -> lifting -> unit

end;

(* 
  val lift_typ : (Var.pname * Var.typ) list -> Var.typ -> Var.typ
  val lift_ienv_typs : (Var.pname * Var.typ) list -> InstEnv.T -> InstEnv.T
  val lift_vars : (Var.pname * Var.typ) list * InstEnv.T -> T -> T *)


structure DB_Lifting 
= struct

(* lift ps_to_vs over given param list *)
datatype lifting = 
         Lifting 
         of (* lift over these: params to add to context of new vars *)
            (Trm.Free.name * Trm.typ) list 
            (* new vars *)
            * (Var.name * Trm.typ) Trm.Free.NTab.T; 

fun dest_lifting (Lifting rep) = rep;

val empty = Lifting ([],Trm.TrmParams.NTab.empty);


fun lift (Lifting (overplist, ps_to_vs)) t =
    let (*computes t(Bound(n+k-1),...,Bound(n))  *)
      fun combound (t, []) = t 
        | combound (t, h::l) = 
          combound (t, l) $ (Free h)
      fun incr (fv as Free (x, T)) = 
          (case Trm.TrmParams.NTab.lookup ps_to_vs x 
            of NONE => fv
             | SOME x2ty => combound (Var x2ty, overplist))
        | incr (Abs (x, T, body)) = Abs (x, T, incr body)
        | incr (t $ u) = (incr t) $ (incr u)
        | incr x = x;
    in incr t end;

(* change params into vars, avoiding given vars, make a 
       param to new vars table lifted over overps params *)
(* Note: ignores type variables. *)
fun mk overps ptab ienv = 
    let 
      val lift_over_params = Trm.TrmParams.get_plist overps
      val lift_over_typs = map snd (rev lift_over_params)
      fun varify1 (n,ty) (pstovs, ienv2) = 
          let 
            val ty2 = lift_over_typs ---> ty
            val (n2,ienv3) = 
                InstEnv.new_uninst_var (Trm.var_of_free_name n, ty2) ienv2
          in (Trm.TrmParams.NTab.update (n,(n2,ty2)) pstovs, ienv3) end
      val (pstovs,ienv') = 
          fold_rev varify1 (Trm.TrmParams.get_plist ptab) 
                   (Trm.TrmParams.NTab.empty, ienv)
    in (Lifting (lift_over_params,pstovs), ienv') end;

fun pretty ctxt (Lifting (overplist, ps_to_vs)) = 
    Pretty.chunks 
      [Pretty.str "Lift vars: ",
       Pretty.list "[" "]" 
                   (map (fn (n,(v,ty)) => 
                            Pretty.block 
                              [Trm.Free.pretty_name n, 
                               Pretty.str " -> ",
                               Var.pretty_name v,
                               Pretty.str " : ",
                               Trm.pretty_typ ctxt ty])
                        (Trm.TrmParams.NTab.list_of ps_to_vs)),
       Pretty.str "Over params: ",
       Pretty.list "[" "]"
                   (map (fn (n,ty) => 
                            Pretty.block 
                              [Trm.Free.pretty_name n, 
                               Pretty.str " : ",
                               Trm.pretty_typ ctxt ty])
                        overplist)];

val print = Pretty.writeln oo pretty;


end;


structure Lifting : LIFTING = DB_Lifting;




(* 
fun lift_typ plist ty = (rev (map snd plist)) ---> ty;

fun lift_vtab_typs plist (tyvtab, vtab) = 
    (tyvtab, Var.NTab.map_all (lift_typ plist) vtab);

fun lift_vars (overplist, vtab) t =
    let 
      val mknewtyp ty = 

      (*computes t(Bound(n+k-1),...,Bound(n))  *)
      fun combound (t, []) = t 
        | combound (t, h::l) = 
          combound (t, l) $ (Free h)
      fun incr (v as Var (x, ty)) = 
          (case Var.NTab.lookup vs x 
            of NONE => v
             | SOME ty2 => 
             combound (Var(x,ty2), overplist))
        | incr (Abs (x, T, body)) = Abs (x, T, incr body)
        | incr (t $ u) = (incr t) $ (incr u)
        | incr x = x;
    in incr t end;
*)
