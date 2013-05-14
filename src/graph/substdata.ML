signature GRAPH_SUBST_DATA =
sig
  structure GoalTyp : GOAL_TYP

  (* TO DO: allow variables inside a rtechn? *)
  datatype vdata = RT of RTechn.T
                 | GN of GNode.T list (* fixme: should be goalnode *)
                 | TVar of string (* variable of rtechn *)
                 | GVar of string (* variable of goalnode *)

  (* TO DO: allow variables inside a goaltype? *)
  datatype edata = GT of GoalTyp.T
                 | EVar of string (* variable of goalnode *)

  type subst = vdata StrName.NTab.T * edata StrName.NTab.T
 
  val vdata_eq : vdata * vdata -> bool
  val vdata_ord : vdata * vdata -> order
  val edata_eq : edata * edata -> bool
  val edata_ord : edata * edata -> order

  val empty_subst : subst
  val compose_subst : subst * subst -> subst
  
  val pretty_vdata : vdata -> Pretty.T
  val pretty_edata : edata -> Pretty.T
  val pretty_subst : subst -> Pretty.T
  val print_vdata : vdata -> unit
  val print_edata : edata -> unit
  val print_subst : subst -> unit
end

(* combine data to allow substitutions on both vertex and edge *)
functor GraphSubstDataFun (GoalTyp : GOAL_TYP) : GRAPH_SUBST_DATA
= struct
  
  structure GoalTyp = GoalTyp;

  (* TO DO: allow variables inside a rtechn? *)
  datatype vdata = RT of RTechn.T
                 | GN of GNode.T list (* fixme: should be goalnode *)
                 | TVar of string (* variable of rtechn *)
                 | GVar of string (* variable of goalnode *)

  (* TO DO: allow variables inside a goaltype? *)
  datatype edata = GT of GoalTyp.T
                 | EVar of string (* variable of goalnode *)

  (* ordering for vertex data *)
  fun vdata_ord (TVar v1,TVar v2) = String.compare (v1,v2)
    | vdata_ord (TVar v1,TVar v2) = String.compare (v1,v2)
    | vdata_ord (TVar _,_) = LESS
    | vdata_ord (GVar _,_) = LESS
    | vdata_ord (GN _, RT _) = LESS
    | vdata_ord (RT _, GN _) = GREATER
    | vdata_ord (GN g1, GN g2) = Int.compare (length g1,length g2) (* FIXME *)
    | vdata_ord (RT r1, RT r2) = RTechn.ord (r1,r2);
  fun vdata_eq (xy as (x, y)) = 
      (case vdata_ord xy of EQUAL => true
          | _ => false);

  fun edata_ord (EVar v1,EVar v2) = String.compare (v1,v2)
    | edata_ord (EVar v1,_) = LESS
    | edata_ord (GT _,EVar _) = GREATER
    | edata_ord (GT g1,GT g2) = EQUAL (* FIXME!!! *)
  fun edata_eq (xy as (x, y)) = 
      (case edata_ord xy of EQUAL => true
          | _ => false);

  type subst = vdata StrName.NTab.T * edata StrName.NTab.T
  val empty_subst = (StrName.NTab.empty,StrName.NTab.empty);
  fun compose_subst ((v1,e1),(v2,e2)) = 
        (StrName.NTab.merge_joint vdata_eq v1 v2,
         StrName.NTab.merge_joint edata_eq e1 e2);

  (* pretty printing *)

  fun pretty_vdata (RT rt) = RTechn.pretty rt
   |  pretty_vdata (GN gn) = Pretty.block (Pretty.commas (map GNode.pretty gn))
   |  pretty_vdata (TVar s) = Pretty.str ("?T_" ^ s)
   |  pretty_vdata (GVar s) = Pretty.str ("?G_" ^ s);
  val print_vdata = Pretty.writeln o pretty_vdata;

  fun pretty_edata (GT gt) = G.pretty_name (GoalTyp.get_name gt)
   |  pretty_edata (EVar v) = Pretty.str ("?" ^ v)
  val print_edata = Pretty.writeln o pretty_edata;

  fun pretty_subst (vsubst,esubst) =
    Pretty.block [Pretty.str "vertex subst: ",StrName.NTab.pretty pretty_vdata vsubst,
                  Pretty.str "edge subst: ",StrName.NTab.pretty pretty_edata esubst];
  val print_subst = Pretty.writeln o pretty_subst;  
end;


