(* an actual goalnode *)
structure GoalNode =
struct
  exception goaltype_exp of string
 (* also includes the full wire!! *)
  type T = FullWire.name * GN.NSet.T;

  fun get_wire (w,_) = w;
  fun get_gnodes (_,gnds) = gnds;

  val get_all_goals = GNodeSet.get_all_goals o get_gnodes;

 fun empty_goalnode w = (w,GN.NSet.empty);
 val default_goalnode = empty_goalnode GNode.Wire.default_wire;
 fun is_empty (_,gs) = GN.NSet.is_empty gs;

 fun merge (w1,ws1) (w2,ws2) = 
   if GNode.Wire.eq (w1,w2) 
    then (w1,GN.NSet.union_merge ws1 ws2)
    else raise goaltype_exp "not the same wires";

  fun lookup_fact ws fact = 
    case W.NSet.lookup ws fact of
     NONE => raise FullWire.undefined_exp "no such fact"
     | SOME (_,n) => n;

  fun subfact th w2 fact =  (* relies on matching on name and same name *)
    BWire.sub_wire th fact (lookup_fact w2 fact);

 (* not really sure this is correct *)
 fun valid_gnode th wire gnode = 
   let
     val facts = FullWire.get_facts wire
     val gfacts = GNode.get_facts gnode |> WTab.get_nameset
   in
      (* all wires are ok (subwire or should it be equal?) *)
      W.NSet.forall (subfact th gfacts) facts
      andalso (* has all props facts *)
      (wire |> FullWire.project_fact_names
            |> SStrName.NSet.forall (fn pname => FullWire.has_name pname gfacts))
   end;

 fun is_valid th (w,gnds) = 
   FullWire.valid_wire w andalso
   GN.NSet.forall (valid_gnode th w) gnds;

 fun match_gset_bwire rst (bw,gs) = 
   Goaln.NSet.forall (BWire.match bw rst) gs;

 fun match_gnode rst w gnd =
   (* goal matches type *)
   BWire.match (GNode.get_gtyp gnd) rst (GNode.get_goal gnd)
   andalso
   (* all hyps in gnd must match their wire! *) 
   WTab.forall (match_gset_bwire rst) (GNode.get_facts gnd)
   andalso
   (* all properties holds *)
   RF.NSet.forall (fn r => (RelFeature.get_match r) gnd rst) (FullWire.get_props w);

 (* match for complete goalnode set *)
 fun match rst w = GN.NSet.forall (match_gnode rst w);

end (* structure *)


