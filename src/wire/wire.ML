structure Wire =
struct
  
  exception undefined_exp of string

  (* eq is currently on name only!
      - should be on the features!
      - should we even bother with having named wires?
 *)
  datatype fwire = Wire of { 
    name : SStrName.name, 
    facts : W.NSet.T, 
    goal : W.NSet.name, 
    props : RF.NSet.T};

  fun get_name (Wire rep) = #name rep;
  fun get_facts (Wire rep) = #facts rep;
  fun get_goal (Wire rep) = #goal rep;
  fun get_props (Wire rep) = #props rep;

  fun update_name f (Wire rep) = Wire {name = f (#name rep), facts = #facts rep,
                                       goal = #goal rep, props = #props rep};
  fun update_facts f (Wire rep) = Wire {name = #name rep, facts = f (#facts rep),
                                        goal = #goal rep, props = #props rep};
  fun update_goal f (Wire rep) = Wire {name = #name rep, facts = #facts rep,
                                       goal = f (#goal rep), props = #props rep};
  fun update_props f (Wire rep) = Wire {name = #name rep, facts = #facts rep,
                                        goal = #goal rep, props = f (#props rep)};

  val set_name = update_name o K;
  val set_facts = update_facts o K;
  val set_goal = update_goal o K;
  val set_props = update_props o K;  

  (* relies on matching on name only *)
  fun lookup_fact wire fact = 
    case W.NSet.lookup (get_facts wire) fact of
     NONE => raise undefined_exp "no such fact"
     | SOME (_,n) => n;

(*
  fun subfact th w2 fact =  (* relies on matching on name and same name *)
    BWire.sub_wire th fact (lookup_fact w2 fact);   
*)
(*
  fun subwire th w1 w2 = 
    BWire.sub_wire th (get_goal w1) (get_goal w2)
   andalso (* assume same name for facts!! *)
    W.NSet.forall (subfact th w2) (get_facts w1);
   (* and also properties *)
*)

  fun project_fact_names w =
    RF.NSet.fold 
     (fn p => fn fns => SStrName.NSet.union_merge fns (RelFeature.project_fact_names p)) 
     (get_props w) 
     SStrName.NSet.empty;

  fun has_name name =
     W.NSet.exists (fn bw => SStrName.name_eq (BWire.get_name bw,name));

  fun has_fact w name = get_facts w |> has_name name;
 
  fun valid_wire w =
    w |> project_fact_names
      |> SStrName.NSet.forall (has_fact w);

  val default_wire = 
    Wire {name = SStrName.mk "default_wire", 
          facts = W.NSet.empty,
          goal = BWire.default_wire,
          props = RF.NSet.empty};

(*
  fun goal_embeds gwire factwire = 
    Wire {name = SStrName.mk "goal_embeds", 
          facts = W.NSet.single factwire,
          goal = gwire,
          props = RelFeature.embedded_in_goal (BWire.get_name factwire) |> RF.NSet.single};
*)

  (* for name set *)
  type name = fwire;
  fun suc f = set_name (SStrName.Namer.suc (get_name f)) f
  fun pred f = case (SStrName.Namer.pred (get_name f)) of
                 NONE => NONE
                | SOME n => SOME (set_name n f);
  fun ord (f1,f2) = SStrName.Namer.ord (get_name f1,get_name f2);
  fun eq (f1,f2) = (ord(f1,f2) = EQUAL);
  fun pretty w = Pretty.block 
                   ((map BWire.pretty (get_facts w |> W.NSet.list_of))
                   @ [Pretty.str " |- ",BWire.pretty (get_goal w)]);
                 
end; (* structure *)

structure W = NameFun(structure Namer = Wire val default_name = Wire.default_wire);

