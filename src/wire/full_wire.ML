functor FWireFun (Wire : BASIC_WIRE) =
struct

   structure Wire = Wire;

   datatype wire = Wire of {facts : Wire.NSet.T, goal : Wire.name};

  fun get_goal (Wire rep) = #goal rep;
  fun get_facts (Wire rep) = #facts rep;

  fun update_goal f (Wire rep) = Wire {facts = #facts rep, goal = f (#goal rep)};
  fun update_facts f (Wire rep) = Wire {facts = f (#facts rep), goal = #goal rep};

  val set_goal = update_goal o K;
  val set_facts = update_facts o K;

  fun add_fact fact = update_facts (Wire.NSet.add fact);
  fun delete_fact fact = update_facts (Wire.NSet.delete fact);
  fun delete_matching_facts fact wire = 
    let 
      fun update f fs = if Wire.wire_match fact f then Wire.NSet.delete f fs else fs
    in
      update_facts ((Wire.NSet.fold update) (get_facts wire)) wire
    end;

  val default_wire = Wire {facts = Wire.NSet.empty, goal = Wire.default_wire};

  structure WireNamer =
  struct
   type name = wire
   fun suc (Wire rep) = update_goal Wire.suc (Wire rep);
   fun pred wire = case Wire.pred (get_goal wire) of
                           NONE => NONE
                         | SOME v => SOME (set_goal v wire);
   fun ord (n1,n2) =
     case  Wire.ord (get_goal n1, get_goal n2) of
      LESS => LESS
     | EQUAL => Wire.NSet.ord (get_facts n1, get_facts n2)
     | GREATER => GREATER;

   fun eq (n1,n2) = Wire.eq (get_goal n1, get_goal n2) andalso 
                   Wire.NSet.eq (get_facts n1) (get_facts n2);
   fun pretty name = Pretty.str "" 
  end;

  structure Basic_WireName = 
    BasicNameFun(struct structure Namer = WireNamer val default_name = default_wire end);

  structure WireSet = NameSetFun(Basic_WireName);

 (* fixme: could use order as done in wire.ML to optimise *)
 fun match src dest = 
   Wire.wire_match (get_goal src) (get_goal dest) andalso
   Wire.NSet.forall
     (fn d =>
        Wire.NSet.exists
         (fn s => Wire.wire_match s d) (get_facts src)) (get_facts dest);

end (* functor *)

structure FWire = FWireFun(BWire);


structure WireNode =
struct
  type name = FWire.Wire.name
  type T = FWire.Wire.name * FWire.wire;

  fun get_main_wire (w,_) = w;
  fun get_fwire (_,fw) = fw;

  fun match (from,fw) (dest,dw) =
     FWire.Wire.wire_match from dest andalso
     FWire.match fw dw;

  structure WInfo =
  struct
   type name = T
   fun suc (wire,gs) = (FWire.Wire.suc wire,gs);
   fun pred (wire,gs) = case FWire.Wire.pred (wire) of
                           NONE => NONE
                         | (SOME v) => SOME (v,gs);
   fun ord ((w1,_),(w2,_)) = FWire.Wire.ord (w1,w2)
   fun eq  ((w1,_),(w2,_)) = FWire.Wire.eq (w1,w2)
   fun pretty (wire,_) = FWire.Wire.pretty wire 
  end;

 val default_wire = (FWire.Wire.default_wire,FWire.default_wire);

  structure W = 
    BasicNameFun(struct structure Namer = WInfo val default_name = default_wire end);

  (* structure WSet = NameSetFun(Basic_WireName); *)

 fun wire_of_goal goal = 
   FWire.Wire { facts = GNode.WTab.get_nameset (GNode.get_facts goal) , goal = GNode.get_gtyp goal};

  fun match_goal_wirenode wire goal = 
    FWire.match wire (wire_of_goal goal);

  fun match_wirenode_goal goal wire = 
    FWire.match (wire_of_goal goal) wire;

  fun match_goal_wire (gwname,gs) (wname,wire) =
    FWire.Wire.wire_match gwname wname andalso
    GNode.GoalSet.forall (match_goal_wirenode wire) gs
    

end; (* structure *)

infixr 4 <:
fun op <: (a,b) = WireNode.match b a;

