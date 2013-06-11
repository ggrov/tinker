signature GRAPH_SUBST_DATA =
sig
  structure GoalTyp : BASIC_GOALTYPE

  datatype gnode = GN_Node of GoalTyp.gnode 
                 | GN_Var of string 
                 | GN_Empty
                 | GN_Pair of gnode * gnode

  datatype vdata = RT of RTechn.T
                 | GN of gnode 
                 | TVar of string (* variable of rtechn *)

  (* TO DO: allow variables inside a goaltype? *)
  datatype edata = GT of GoalTyp.T
                 | EVar of string (* variable of goalnode *)

  datatype subst = Subst of { vertex : vdata StrName.NTab.T,
                              gnode : gnode StrName.NTab.T,
                              edge : edata StrName.NTab.T }

  val gnode_to_list : gnode -> gnode list
  val gnode_of_list : gnode list -> gnode

  val gnode_eq : gnode * gnode -> bool
  val gnode_ord : gnode * gnode -> order
  val vdata_eq : vdata * vdata -> bool
  val vdata_ord : vdata * vdata -> order
  val edata_eq : edata * edata -> bool
  val edata_ord : edata * edata -> order

  val empty_subst : subst
  val compose_subst : subst * subst -> subst
  
  val add_vsubst : (string * vdata) -> subst -> subst
  val add_esubst : (string * edata) -> subst -> subst
  val add_gsubst : (string * gnode) -> subst -> subst

  val lookup_vsubst : subst -> string -> vdata option
  val lookup_esubst : subst -> string -> edata option
  val lookup_gsubst : subst -> string -> gnode option

  val pretty_gnode : gnode -> Pretty.T 
  val pretty_vdata : vdata -> Pretty.T
  val pretty_edata : edata -> Pretty.T
  val pretty_subst : subst -> Pretty.T
  val print_gnode : gnode -> unit 
  val print_vdata : vdata -> unit
  val print_edata : edata -> unit
  val print_subst : subst -> unit
end

(* combine data to allow substitutions on both vertex and edge *)
functor GraphSubstDataFun (GoalTyp : BASIC_GOALTYPE) : GRAPH_SUBST_DATA
= struct

  (* fixme: need to be generalised, e.g. want to have ?g::?gs *)
  (* datatype gnode' = tGn of GNode.T
                  | tL of gnode' list
                  | tV of string *)
   (* then we can get rid of gvar! *)
  
  structure GoalTyp = GoalTyp;

  datatype gnode = GN_Node of GoalTyp.gnode 
                 | GN_Var of string 
                 | GN_Empty
                 | GN_Pair of gnode * gnode

  datatype vdata = RT of RTechn.T
                 | GN of gnode 
                 | TVar of string (* variable of rtechn *)

  (* TO DO: allow variables inside a goaltype? *)
  datatype edata = GT of GoalTyp.T
                 | EVar of string (* variable of goalnode *)

  fun gnode_ord (GN_Node g1 ,GN_Node g2) = GoalTyp.gnode_ord(g1,g2)
   |  gnode_ord (GN_Var s1,GN_Var s2) = String.compare (s1,s2)
   |  gnode_ord (GN_Empty,GN_Empty) = EQUAL
   |  gnode_ord (GN_Pair (x1,x2),GN_Pair (y1,y2)) = 
        (case gnode_ord (x1,y1) of
          EQUAL => gnode_ord (x2,y2)
        | x => x )        
   |  gnode_ord (GN_Var _, _) = LESS
   |  gnode_ord (GN_Empty,GN_Var _) = GREATER
   |  gnode_ord (GN_Empty, _) = LESS
   |  gnode_ord (GN_Node _,GN_Var _) = GREATER
   |  gnode_ord (GN_Node _,GN_Empty) = GREATER
   |  gnode_ord (GN_Node _,GN_Pair _) = LESS
   |  gnode_ord (_, _) = GREATER (* list is greatest *)
  fun gnode_eq (xy as (x, y)) = 
      (case gnode_ord xy of EQUAL => true
          | _ => false);
  (* must be list combinator for this..*)


  (* ordering for vertex data *)
  fun vdata_ord (TVar v1,TVar v2) = String.compare (v1,v2)
    | vdata_ord (GN g1, GN g2) = gnode_ord (g1,g2)
    | vdata_ord (RT r1, RT r2) = RTechn.ord (r1,r2)
    | vdata_ord (TVar _,_) = LESS
    | vdata_ord (RT _,TVar _) = GREATER
    | vdata_ord (RT _,GN _) = LESS
    | vdata_ord (GN _, _) = GREATER;
  fun vdata_eq (xy as (x, y)) = 
      (case vdata_ord xy of EQUAL => true
          | _ => false);

  fun edata_ord (EVar v1,EVar v2) = String.compare (v1,v2)
    | edata_ord (EVar v1,GT _) = LESS
    | edata_ord (GT _,EVar _) = GREATER
    | edata_ord (GT g1,GT g2) = GoalTyp.ord(g1,g2); (* FIXME!!! *)
  fun edata_eq (xy as (x, y)) = 
      (case edata_ord xy of EQUAL => true
          | _ => false);

  datatype subst = Subst of { vertex : vdata StrName.NTab.T,
                              gnode : gnode StrName.NTab.T,
                              edge : edata StrName.NTab.T }

  fun add_vsubst (n,v) (Subst subst) = 
   Subst { vertex = StrName.NTab.ins (n,v) (#vertex subst),
           gnode = #gnode subst,
           edge = #edge subst }
  fun add_gsubst (n,v) (Subst subst) = 
   Subst { vertex = #vertex subst,
           gnode = StrName.NTab.ins (n,v) (#gnode subst),
           edge = #edge subst }
  fun add_esubst (n,v) (Subst subst) = 
   Subst { vertex = #vertex subst,
           gnode = #gnode subst,
           edge = StrName.NTab.ins (n,v) (#edge subst) }

  fun lookup_vsubst (Subst {vertex,...}) = 
      StrName.NTab.lookup vertex;
  fun lookup_esubst (Subst {edge,...}) = 
      StrName.NTab.lookup edge;
  fun lookup_gsubst (Subst {gnode,...}) = 
      StrName.NTab.lookup gnode;

  val empty_subst = 
    Subst { vertex = StrName.NTab.empty,
            gnode = StrName.NTab.empty,
            edge = StrName.NTab.empty};

  fun compose_subst (Subst s1,Subst s2) =
    Subst { vertex = StrName.NTab.merge_joint vdata_eq (#vertex s1) (#vertex s2),
            gnode = StrName.NTab.merge_joint gnode_eq (#gnode s1) (#gnode s2),
            edge = StrName.NTab.merge_joint edata_eq (#edge s1) (#edge s2)};

  fun gnode_to_list (GN_Pair (g1,g2)) = gnode_to_list g1 @ gnode_to_list g2
   |  gnode_to_list x = [x]

  fun gnode_of_list [] = GN_Empty
   |  gnode_of_list (x::xs) = GN_Pair(x,gnode_of_list xs)
 
  (* pretty printing *)

  fun pretty_gnode (GN_Node gn) = GoalTyp.pretty_gnode gn 
   |  pretty_gnode (GN_Var s) = Pretty.str ("?G_" ^ s)
   |  pretty_gnode GN_Empty = Pretty.str "[]"
   |  pretty_gnode (GN_Pair (g1,g2)) = Pretty.block [pretty_gnode g1,Pretty.str " :: ",pretty_gnode g2];

  val print_gnode = Pretty.writeln o pretty_gnode;

  fun pretty_vdata (RT rt) = RTechn.pretty rt
   |  pretty_vdata (GN gn) = pretty_gnode gn
   |  pretty_vdata (TVar s) = Pretty.str ("?T_" ^ s)

  val print_vdata = Pretty.writeln o pretty_vdata;

  fun pretty_edata (GT gt) = GoalTyp.pretty gt
   |  pretty_edata (EVar v) = Pretty.str ("?" ^ v)
  val print_edata = Pretty.writeln o pretty_edata;

  fun pretty_subst (Subst {vertex,gnode,edge}) =
    Pretty.block [Pretty.str "vertex subst: ",StrName.NTab.pretty pretty_vdata vertex,
                  Pretty.str "gnode subst: ",StrName.NTab.pretty pretty_gnode gnode, 
                  Pretty.str "edge subst: ",StrName.NTab.pretty pretty_edata edge];
  val print_subst = Pretty.writeln o pretty_subst;  
end;


