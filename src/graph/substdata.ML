(* to do: all should be in a single file *)

signature GRAPH_SUBST_DATA =
sig
  structure GoalTyp : BASIC_GOALTYPE

  (* note: variables only for evaluation! *)
  datatype nvdata = RT of RTechn.T
                 | GN of GoalTyp.gnode 
                 | TVar of string (* variable of rtechn *)
                 | GVar of string (* variable of gnode *)
  datatype edata = GT of GoalTyp.T
                 | EVar of string (* variable of goalnode *)

  datatype subst = Subst of { vertex : RTechn.T StrName.NTab.T,
                              gnode : gnode StrName.NTab.T,
                              edge : edata StrName.NTab.T }

  type psubst = subst

  val nvdata_eq : nvdata * nvdata -> bool
  val edata_eq : edata * edata -> bool

  val empty_subst : subst
  val compose_subst : subst * subst -> subst
  
  val add_vsubst : (string * vdata) -> subst -> subst
  val add_esubst : (string * edata) -> subst -> subst
  val add_gsubst : (string * gnode) -> subst -> subst

  val lookup_vsubst : subst -> string -> vdata option
  val lookup_esubst : subst -> string -> edata option
  val lookup_gsubst : subst -> string -> gnode option

  val pretty_theory_name : Pretty.T

  (* A partial substitution contains a collection of constraints on pattern
   * variables. It is initialised by passing in a table containing node/edge
   * data from the pattern and target graphs. This can be used e.g. to ensure that names
   * introduced in the pattern are fresh. *)
  val init_psubst_from_data :
    nvdata VTab.T * edata ETab.T ->
    nvdata VTab.T * edata ETab.T -> psubst

  (* The match_xxx functions update a psubst or return NONE if
   * no match is possible. *)
  val match_nvdata : nvdata * nvdata -> psubst -> psubst option
  val match_edata : edata * edata -> psubst -> psubst option

  (* default vertex and edge data *)
  val default_nvdata : nvdata
  val default_edata : edata

  (* COMPAT: needed for old controller *)
  val default_nvdata_of_typestring : string -> nvdata
  (* COMPAT: needed for old controller *)
  val default_edata_of_typestring  : string -> edata

  val pretty_nvdata : nvdata -> Pretty.T
  val pretty_edata : edata -> Pretty.T

  (* For cases where node/edge data cannot be unified greedily (or uniquely),
   * this is called just before the match is finalised. One match will be
   * produced for each subst returned. In the case where this hook isn't
   * needed, let "type subst = psubst", and "solve_psubst = Seq.single". *)
  val solve_psubst : psubst -> subst Seq.seq

  (* Apply substitutions to data. *)
  val subst_in_nvdata : subst -> nvdata -> subst * nvdata
  val subst_in_edata : subst -> edata -> subst * edata


end

functor GraphSubstDataFun (GoalTyp : BASIC_GOALTYPE) : GRAPH_SUBST_DATA
= struct

  structure GoalTyp = GoalTyp;
  
  datatype nvdata = RT of RTechn.T
                 | GN of GoalTyp.gnode 
                 | TVar of string (* variable of rtechn *)
                 | GVar of string (* variable of gnode *)

  datatype edata = GT of GoalTyp.T
                 | EVar of string (* variable of goalnode *)

  fun nvdata_eq (RT r1,RT r2) = RTechn.eq (r1,r2)
   |  nvdata_eq (GN g1,GN g2) = GoalTyp.gnode_eq (g1,g2)
   |  nvdata_eq (TVar v1,TVar v2) = String.eq (v1,v2)
   |  nvdata_eq (GVar v1,GVar v2) = String.eq (v1,v2)
   |  nvdata_eq _ = false;

 fun edata_eq (GT gt1,GT gt2) = GoalTyp.eq (gt1,gt2)
  |  edata_eq (EVar v1,EVar v2) = String.eq (v1,v2);


  datatype subst = Subst of { vertex : RTechn.T StrName.NTab.T,
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

  (* matching *)

  fun match_data (TVar v,RT rt) subst = 
        (case lookup_vsubst subst v of
            NONE => SOME (add_vsubst (v,rt) subst) (* bind vi if not bound *)
          | SOME rt' => if RTechn.eq (rt,rt') then SOME subst else NONE)
    | match_nvdata (GVar v, GN gn) subst =
        (case lookup_gsubst subst v of
            NONE => SOME (add_gsubst (v,gn) subst) (* bind vi if not bound *)
          | SOME gn' => if GoalType.gnode_eq (gn,gn') then SOME subst else NONE )
    | match_nvdata (RT r1, RT r2) subst = 
         if RTechn.eq (r1,r2) then SOME subst else NONE
    | match_nvdata (GN gn1, GN gn2) subst =
         if GoalTyp.gnode_eq(g1,g2) then SOME subst else NONE
    | match_nvdata (_,_) subst = NONE;

  fun match_edata (EVar v1,e) subst =
      (case lookup_esubst subst v1 of
            NONE => SOME (add_esubst (v1,e) subst)
          | SOME e2 => if edata_eq(e,e2) then SOME subst else NONE)
   |  match_data (GT gt1,GT gt2) subst = 
        if GoalTyp.eq(gt1,gt2) then SOME subst else NONE
   |  match_data (GT _,EVar _) _ = NONE






  (* pretty printing *)

  val print_gnode = Pretty.writeln o pretty_gnode;

  fun pretty_nvdata (RT rt) = RTechn.pretty rt
   |  pretty_nvdata (GN gn) = GoalTyp.pretty_gnode gn
   |  pretty_nvdata (TVar s) = Pretty.str ("?T_" ^ s)
   |  pretty_nvdata (GVar s) = Pretty.str ("?T_" ^ s)

  val print_vdata = Pretty.writeln o pretty_vdata;

  fun pretty_edata (GT gt) = GoalTyp.pretty gt
   |  pretty_edata (EVar v) = Pretty.str ("?" ^ v)
  val print_edata = Pretty.writeln o pretty_edata;

  fun pretty_subst (Subst {vertex,gnode,edge}) =
    Pretty.block [Pretty.str "vertex subst: ",StrName.NTab.pretty pretty_vdata vertex,
                  Pretty.str "gnode subst: ",StrName.NTab.pretty pretty_gnode gnode, 
                  Pretty.str "edge subst: ",StrName.NTab.pretty pretty_edata edge];
  val print_subst = Pretty.writeln o pretty_subst;  

  (* add all configurations required here *)

end;


