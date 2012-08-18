structure RelFeature =
struct

  datatype element = Goal | Fact of SStrName.name
  datatype prop = Rel of prop * prop
                | Atom of element
                | Elements of element list
                | Empty

  (* Fixme: need a goalnode to fix on! *)
  datatype T = Prop of 
    {name : SStrName.name,
     prop : prop,
     match : GNode.goal -> RState.T -> bool}

  fun get_name (Prop rep) = #name rep;
  fun get_prop (Prop rep) = #prop rep;
  fun get_match (Prop rep) = #match rep;

  fun update_name f (Prop rep) = Prop {name = f (#name rep), prop = #prop rep, match = #match rep};
  fun update_prop f (Prop rep) = Prop {name = #name rep, prop = f (#prop rep), match = #match rep}; 
  fun update_match f (Prop rep) = Prop {name = #name rep, prop = #prop rep, match = f (#match rep)}; 
 
  val set_name = update_name o K;
  val set_prop = update_prop o K;
  val set_match = update_match o K;

  fun project_fact_names_element Goal = []
   | project_fact_names_element (Fact f) = [f];

  fun project_fact_names' (Rel (p1,p2)) = (project_fact_names' p1) @ (project_fact_names' p2)
   | project_fact_names' (Atom e) = project_fact_names_element e
   | project_fact_names' (Elements els) = maps project_fact_names_element els
   | project_fact_names' _ = [];

  val project_fact_names = SStrName.NSet.of_list o project_fact_names' o get_prop;

  val default_prop = Prop {name = SStrName.mk "any", prop = Empty, match = K (K true)};

  (* for name set *)
  type name = T;
  fun suc f = set_name (SStrName.Namer.suc (get_name f)) f
  fun pred f = case (SStrName.Namer.pred (get_name f)) of
                 NONE => NONE
                | SOME n => SOME (set_name n f);
  fun ord (f1,f2) = SStrName.Namer.ord (get_name f1,get_name f2);
  fun eq (f1,f2) = (ord(f1,f2) = EQUAL);
  fun pretty f = Pretty.str (SStrName.dest (get_name f));

  fun goal_concl_term g pplan =
      PPlan.get_varified_ltrm pplan g |> Logic.strip_imp_concl;

  exception relfeature_exp of string * T option

  fun lookup_fact fact_name gnode = 
    case GNode.lookup_facts_by_name fact_name gnode of
      SOME gs => gs
     | NONE => raise  relfeature_exp ("no fact of name ",NONE);

  (* examples *)

  fun embedded_in_goal fact_name = 
   let
     fun term_of rst g = goal_concl_term g (RState.get_pplan rst)
     fun check gnode rst t = 
        TermFeatures.ctxt_embeds (RState.get_ctxt rst) (term_of rst t) (term_of rst (GNode.get_goal gnode))
     fun match gnode rst = 
        Goaln.NSet.exists (check gnode rst) (lookup_fact fact_name gnode)
   in
    Prop {name = SStrName.mk "embeds", prop = Rel (Atom (Fact fact_name),Atom Goal), match = match}
   end;
  
end;

structure RF = NameFun(structure Namer = RelFeature val default_name = RelFeature.default_prop);
