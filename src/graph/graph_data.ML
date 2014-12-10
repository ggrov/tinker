functor PSGraphDataFun (GoalTyp : BASIC_GOALTYPE) : PSGRAPH_DATA
= struct

  structure GoalTyp = GoalTyp;

  type arg_typ = string list list
  
  (* note: variables only for evaluation! *)
  datatype nvdata = T_Atomic of { name : string, args : arg_typ}
                  | T_Graph of { name : string, args : arg_typ, is_or : bool}
                  | T_Identity 
                  | G_Break (* breakpoint *)
                  | G of GoalTyp.gnode 
                  | T_Var of string (* variable of rtechn *)
                  | G_Var of string (* variable of gnode *)
   (* example Atomic 
          rule,[[exI]]
          frule[[exI],[X,Y]]
          erule(exE,X,Y)
          simp[["add","a","b"]]
          auto[["simp add", "a"],["intro","d"]]
        Nested : use args as input output for variable binding *)

  datatype edata  = GT of GoalTyp.T
                  | GT_Var of string (* variable of goalnode *)

  exception node_exp of string * nvdata;

  (* tactic nodes *)

  fun get_name (T_Atomic {name,...}) = name
   |  get_name (T_Graph {name,...}) = name
   |  get_name nd = raise node_exp ("node does not have a name",nd);

  fun get_args (T_Atomic {args,...}) = args
   |  get_args (T_Graph {args,...}) = args
   |  get_args nd = raise node_exp ("node does not have args",nd);

  fun get_is_or (T_Graph {is_or,...}) = is_or
   |  get_is_or nd = raise node_exp ("not nested tactic node",nd);

  fun update_name f (T_Atomic rep) = 
      T_Atomic { name = f (#name rep), args = #args rep}
   | update_name f (T_Graph rep) = 
      T_Graph { name = f (#name rep), args = #args rep, is_or = #is_or rep}
   | update_name _ nd = raise node_exp ("node does not have a name",nd);

  fun update_args  f (T_Atomic rep) = 
        T_Atomic { name = (#name rep), args = f (#args rep)}
   |  update_args  f (T_Graph rep) = 
        T_Graph { name = #name rep, args = f (#args rep), is_or = #is_or rep}
   | update_args  _ nd =  raise node_exp ("node does not have args",nd);

 fun update_is_or f (T_Graph rep) = 
      T_Graph { name =  (#name rep), args = #args rep, is_or = f (#is_or rep)}
  | update_is_or _ T =   raise node_exp ("not a graph tactic",T);

  val set_name = update_name o K;
  val set_args = update_args o K;
  val set_is_or = update_is_or o K;

  val identity = T_Identity;
  val break_point =  G_Break; (* breakpoint *)

  fun is_tactic_node (T_Atomic _) = true
   |  is_tactic_node (T_Graph _)  = true
   |  is_tactic_node T_Identity  = true
   |  is_tactic_node _ = false;

  fun is_atomic (T_Atomic _) = true
   |  is_atomic _ = false;

  fun is_nested (T_Graph _) = true
   |  is_nested _ = false;

  fun is_identity T_Identity = true
   |  is_identity _ = false;

  fun is_break_point G_Break = true
   |  is_break_point _ = false;

  fun is_or (T_Graph {is_or, ...}) = SOME is_or
   |  is_or _ = NONE

  fun is_or' T = 
    case is_or T of 
      SOME v => v
    | NONE => false;

  (* node equality *)

  fun nvdata_eq (T_Atomic a1,T_Atomic a2) = 
     #name a1 = #name a2 andalso #args a1 = #args a2
   | nvdata_eq (T_Graph n1,T_Graph n2) = 
     #name n1 = #name n2 andalso #args n1 = #args n2 andalso #is_or n1 = #is_or n2
   | nvdata_eq (T_Identity,T_Identity) = true 
   | nvdata_eq (G_Break,G_Break) = true 
   |  nvdata_eq (G g1,G g2) = GoalTyp.gnode_eq (g1,g2)
   |  nvdata_eq (T_Var v1,T_Var v2) = (v1 = v2)
   |  nvdata_eq (G_Var v1,G_Var v2) = (v1 = v2)
   |  nvdata_eq _ = false;

 fun edata_eq (GT gt1,GT gt2) = GoalTyp.eq (gt1,gt2)
  |  edata_eq (GT_Var v1,GT_Var v2) = (v1 = v2)
  |  edata_eq _ = false;

  (* substution: for tactic gnode and edge *)
  datatype subst = Subst of { tactic : nvdata StrName.NTab.T,
                              gnode : GoalTyp.gnode StrName.NTab.T,
                              edge : edata StrName.NTab.T }

  (* fixme : not sure how to use psubst *)
  type psubst = subst; 

  fun add_vsubst (n,v) (Subst subst) = 
   Subst { tactic = StrName.NTab.ins (n,v) (#tactic subst),
           gnode = #gnode subst,
           edge = #edge subst }
  fun add_gsubst (n,v) (Subst subst) = 
   Subst { tactic = #tactic subst,
           gnode = StrName.NTab.ins (n,v) (#gnode subst),
           edge = #edge subst }
  fun add_esubst (n,v) (Subst subst) = 
   Subst { tactic = #tactic subst,
           gnode = #gnode subst,
           edge = StrName.NTab.ins (n,v) (#edge subst) }

  fun lookup_tsubst (Subst {tactic,...}) = 
      StrName.NTab.lookup tactic;
  fun lookup_esubst (Subst {edge,...}) = 
      StrName.NTab.lookup edge;
  fun lookup_gsubst (Subst {gnode,...}) = 
      StrName.NTab.lookup gnode;

  val empty_subst = 
    Subst { tactic = StrName.NTab.empty,
            gnode = StrName.NTab.empty,
            edge = StrName.NTab.empty};

  fun compose_subst (Subst s1,Subst s2) =
    Subst { tactic = StrName.NTab.merge_joint nvdata_eq (#tactic s1) (#tactic s2),
            gnode = StrName.NTab.merge_joint GoalTyp.gnode_eq (#gnode s1) (#gnode s2),
            edge = StrName.NTab.merge_joint edata_eq (#edge s1) (#edge s2)};

  (* matching *)

  fun match_nvdata (T_Var v,nd) subst = 
      (if (is_tactic_node nd)
       then
        (case lookup_tsubst subst v of
            NONE => SOME (add_vsubst (v,nd) subst) (* bind vi if not bound *)
          | SOME nd' => if nvdata_eq (nd,nd') then SOME subst else NONE)
       else NONE)
    | match_nvdata (G_Var v, G gn) subst =
        (case lookup_gsubst subst v of
            NONE => SOME (add_gsubst (v,gn) subst) (* bind vi if not bound *)
          | SOME gn' => if GoalTyp.gnode_eq (gn,gn') then SOME subst else NONE )
    | match_nvdata (_,T_Var _) _ = NONE
    | match_nvdata (_,G_Var _) _ = NONE  
    | match_nvdata (nd1,nd2) subst =  
       if nvdata_eq(nd1,nd2) then SOME subst else NONE;

  fun match_edata (GT_Var v1,e) subst =
      (case lookup_esubst subst v1 of
            NONE => SOME (add_esubst (v1,e) subst)
          | SOME e2 => if edata_eq(e,e2) then SOME subst else NONE)
   |  match_edata (GT gt1,GT gt2) subst = 
        if GoalTyp.eq(gt1,gt2) then SOME subst else NONE
   |  match_edata (GT _,GT_Var _) _ = NONE

  (* dummy: not sure what this id used for... *)
  val solve_psubst = Seq.single;

  (* I think it should be empty to start with and 
     only instantiated by pattern matching *)
  fun init_psubst_from_data _ _ = empty_subst;

  (* Apply substitutions to data. *)

  fun subst_in_nvdata subst (T_Var v) =
        (case lookup_tsubst subst v of
          NONE => (subst, T_Var v) (* or should it fail? *)
        | (SOME d) => (subst, d))
   |  subst_in_nvdata subst (G_Var v) =
        (case lookup_gsubst subst v of
          NONE => (subst, G_Var v) (* or should it fail? *)
        | SOME d => (subst, G d))
   |  subst_in_nvdata subst nd = (subst,nd);

  fun subst_in_edata subst (GT gt) = (subst, GT gt)
   |  subst_in_edata subst (GT_Var v) = 
        (case lookup_esubst subst v of
          NONE => (subst, GT_Var v)
        | (SOME d) => (subst,d));


  (* default stuff *)

  (* default vertex and edge data *)
  val default_nvdata  = T_Identity;
  val default_edata = GT GoalTyp.default;

  (* dummy values - not used... *)
  val default_nvdata_of_typestring =  K default_nvdata;
  val default_edata_of_typestring = K default_edata;

  (* pretty printing *)

  val pretty_theory_name = Pretty.str "PSGraph";
  (* fixme *)
  fun pretty_nvdata (T_Atomic {name,args}) = Pretty.str name
   |  pretty_nvdata (T_Graph {name,args,is_or}) = Pretty.str name
   |  pretty_nvdata (T_Identity) = Pretty.str "id"
   |  pretty_nvdata (G_Break) = Pretty.str "break_point"
   |  pretty_nvdata (G gn) = Pretty.str "" (* FIXME *)
   |  pretty_nvdata (T_Var s) = Pretty.str ("?T_" ^ s)
   |  pretty_nvdata (G_Var s) = Pretty.str ("?G_" ^ s)

  val print_nvdata = Pretty.writeln o pretty_nvdata;

  fun pretty_edata (GT gt) = Pretty.str "" (* FIXME *)
   |  pretty_edata (GT_Var v) = Pretty.str ("?" ^ v)
  val print_edata = Pretty.writeln o pretty_edata;

  fun pretty_subst (Subst {tactic,gnode,edge}) =
    Pretty.block [Pretty.str "vertex subst: ",StrName.NTab.pretty pretty_nvdata tactic,
           (* FIXME *)
           (*     Pretty.str "gnode subst: ",StrName.NTab.pretty GoalTyp.pretty_gnode gnode, *) 
                  Pretty.str "edge subst: ",StrName.NTab.pretty pretty_edata edge];
  val print_subst = Pretty.writeln o pretty_subst;  

  (* add all configurations required here *)

  structure Sharing = 
  struct
    type nvdata = nvdata
    type edata = edata
    structure GoalTyp = GoalTyp.BasicSharing
  end

end;


