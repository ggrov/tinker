(* FIXME: Need a way to create a new wire etc... *)
(* this should be handled by wset though *)

(* components required by functor *)
signature BASIC_WIRE_ITEMS = 
sig
  include NAMER;
  
  (* new stuff *)
  val default_wire : name 
  val wire_match : name -> name -> bool (* is wire order also required? *)
  val of_string : string -> name
  val string_of : name -> string

end;

signature GOAL_MAP =
sig
  type name
  type wset
  type T 

  (* lookup properties *)
  val lookup_nameset : T -> name -> Goaln.NSet.T option
  val lookup_wire : T -> Goaln.name -> name option

  (* get properties *)
  val get_nameset : T -> Goaln.NSet.T
  val get_wset : T -> wset
  val get_wire_nameset : T -> name -> Goaln.NSet.T (* raises exception if no such wire *)
  val get_wset_nameset : T -> wset -> Goaln.NSet.T (* raises exception if no such wire *)
  val get_wire_sub_nameset : T -> name -> Goaln.NSet.T (* includes subwires *)
  val get_wset_sub_nameset : T -> wset -> Goaln.NSet.T (* includes subwires *)
  val get_wire : T -> Goaln.name -> name

  (* update and create *)
  val empty : T
  val add_name : Goaln.name -> name -> T -> T
  val add_nameset : name -> Goaln.NSet.T -> T -> T
  val move_wire : name -> name -> T -> T
  val del_wire : name -> T -> T 
  val del_wset : wset -> T -> T
  val del_name : Goaln.name -> T -> T 
  val del_nameset : Goaln.NSet.T -> T -> T

  (* restricts wire *)
  val restr_wset : wset -> T -> T
  val restr_wire : name -> T -> T
  val restr_name : Goaln.name -> T -> T
  val restr_nameset : Goaln.NSet.T -> T -> T
 
  val restr_sub_wset : wset -> T -> T (* uses matching to include sub-wires *)
  val restr_sub_wire : name -> T -> T (* uses matching to include sub-wires *)

 (* combinations -- maybe better to open the structure *)
  val union_merge : T -> T -> T
  val intersect : T -> T -> T
  val subtract : T -> T -> T

  (* pretty printing *)
  val pretty : T -> Pretty.T

end


signature BASIC_WIRE = 
sig
  include BASIC_WIRE_ITEMS;

  type wset (* = NSet.T *)
 (*  type name *)

  structure NSet : NAME_SET (* NAME_SET *)
   sharing type NSet.T = wset
   sharing type NSet.name = name

  structure GMap : GOAL_MAP 
   sharing type GMap.wset = wset
   sharing type GMap.name = name

  val sub_wires : name -> wset -> wset; (* should be derivable from wire_match *)
  val wset_sub_wires : wset -> wset -> wset; (* subwires of a set of wires *)
  val wire_set_match : wset -> wset -> bool
  val get_wire_match_nameset : GMap.T -> name -> Goaln.NSet.T (* includes sub-wires (and no exception) *)
  val get_wset_match_nameset : GMap.T -> wset -> Goaln.NSet.T (* includes sub-wires (and no exception) *)

end;

functor GoalMapFun (structure WSet : NAME
                    structure BWI : BASIC_WIRE_ITEMS
                    sharing type WSet.name = BWI.name ) : GOAL_MAP =
struct
  (* namemap structure *)
  structure WSet = WSet;
  structure GMap = NameMapFun(structure Dom = Goaln and Cod = WSet);

  (* the types *)
  type name = WSet.name; (* is this correct? *)
  type wset = WSet.NSet.T;
  type T = GMap.T;

  (* restricts wire/wset *)

  (* (internal) adds a codom element (if not existing) to empty dom *)
  fun add_empty_wire wire map = 
    if GMap.cod_contains map wire
      then map 
      else GMap.add_to_cod wire Goaln.NSet.empty map;

  (* (internal) adds set of cod  (if not existing) to empty dom *) 
  fun add_empty_wires wset map =
    WSet.NSet.fold add_empty_wire wset map;

  (* restricts to wire if   *)
  fun restrict_wire_with_matching wset map = GMap.get_codset map (* all wires in codomain *)
       (* keep all wires (of codomain) that are more generic then a wire in the wset *)
    |> WSet.NSet.filter (fn codw => WSet.NSet.exists (fn w => BWI.wire_match w codw) wset)
    |> (fn ws => GMap.restrict_cod_to ws map) (* restrict map to these wires *)

  fun restr_sub_wset wset map = restrict_wire_with_matching wset (add_empty_wires wset map);
  fun restr_sub_wire wire map = restr_sub_wset (WSet.NSet.single wire) map;

  fun restr_wset wset map = GMap.restrict_cod_to wset (add_empty_wires wset map);
  fun restr_wire wire map = restr_wset (WSet.NSet.single wire) map;

  fun restr_nameset nms = GMap.restrict_dom_to nms;
  fun restr_name nm = restr_nameset (Goaln.NSet.single nm);

  (* lookups *)
  fun lookup_nameset map wire =
     GMap.lookup_codf map wire;
  fun lookup_wire map goal = 
     GMap.lookup_domf map goal;

  (* get functions *)

  val get_nameset = GMap.get_domset;
  val get_wset = GMap.get_codset;

  fun get_wire_sub_nameset map wire =  get_nameset (restr_sub_wire wire map);
  fun get_wset_sub_nameset map wset = get_nameset (restr_sub_wset wset map);

  fun get_wire_nameset map wire =  get_nameset (restr_wire wire map);
  fun get_wset_nameset map wset = get_nameset (restr_wset wset map);

  val get_wire = GMap.domf;
  
  (* update and create *)
  val empty = GMap.empty;
  val add_name = GMap.add_to_dom;
  val add_nameset = GMap.add_to_cod;

  val del_wire = GMap.del_cod;
  val del_wset = WSet.NSet.fold del_wire;
  val del_name = GMap.del_dom; 
  val del_nameset = Goaln.NSet.fold del_name;

  fun move_wire from to map = 
   let 
      val names = get_wire_nameset map from
   in 
      map |> del_wire from
          |> add_nameset to names
   end;

  fun pretty map =
    GMap.pretty map;

  val union_merge = GMap.union_merge;


  fun contains m a_b = 
    (case GMap.lookup m a_b of SOME true => true | _ => false)
     handle (GMap.not_in_cod_exp _) => false;

  fun subtract m submap = 
    fold (fn (d,c) => fn m => 
            if contains m (d,c) then GMap.del_dom d m else m)
         (GMap.list_of submap)
         m;

  fun intersect m1 m2 =
   fold (fn (d,c) => fn m => 
          if contains m2 (d,c) then GMap.add_to_dom d c m else m)
       (GMap.list_of m1)
       empty; 

end (* GoalMap functor *)


functor BasicWireFun (structure BWI : BASIC_WIRE_ITEMS) : BASIC_WIRE =
struct
  structure BWI = BWI;
  open BWI;
 
  structure WSet = NameFun( structure Namer = BWI 
                              val default_name = BWI.default_wire); 

  structure GMap = GoalMapFun(structure WSet = WSet
                              structure BWI = BWI);

  structure NSet = WSet.NSet;

  type wset = NSet.T;
(*  type name = BWI.name;
  
  val wire_match = BWI.wire_match;
  val default_wire = BWI.default_wire;
  val pretty = BWI.pretty;

  val string_of = BWI.string_of;
  val of_string = BWI.of_string;
*)  
  (* all destination which w matches with *)
  fun sub_wires w = NSet.filter (wire_match w);

  (* wset: source, all_ws : destitions   *)
  fun wset_sub_wires wset all_ws = 
    NSet.fold
     (fn w => fn ws => NSet.union_merge (sub_wires w all_ws) ws)
     wset
     NSet.empty;

  (* FIXME: is this correct? *)
  (* should only be linear: O(N+M) -- relies on order being the same for both*)
  (* I don't think this is needed -- see GMap using exists *)
  fun wire_set_match src_set dest_set =
    let val sws = (NSet.list_of src_set) 
        val dws = (NSet.list_of dest_set)
        fun match (st::sts) (dt::dts) =
             if wire_match st dt 
              then match sts (dt::dts) (* succeeds - could be several wires that match same general input - ok to this due to same order*)
              else match (st::sts) dts (* failure - try next destination wire (until empty then failure of full match) *)
         | match [] [] = true (* hmmm. not sure about correctness *)
         | match [] (_::[]) = true (* hmmm. not sure about correctness -- allows for one more match *)
         | match _ _ = false
    in match sws dws end;

  (* is this correct *)
  fun get_wire_match_nameset map w  =
       NSet.filter (wire_match w) (GMap.get_wset map)
    |> GMap.get_wset_nameset map;

  fun get_wset_match_nameset map wset =
     NSet.fold
      (fn w => NSet.filter (wire_match w))
      (GMap.get_wset map)
      wset (* init value : all are subset of themselves *)
    |> GMap.get_wset_nameset map; 

end; (* functor BasicWireFun *)

structure BasicStrWireItem : BASIC_WIRE_ITEMS =
struct
  structure T = StrIntNamer; (* StrSNamer; *)
  open T;

  fun mk str = (str,0);
  fun dest (str,n) = str ^ (Int.toString n);
  fun str (str,n) = str;

  val default_wire = mk "goal"; (* or empty string? *)
  val of_string = mk;
  val string_of = dest;




  (* meaning that wire.match "x.y" "x" holds, i.e. x <: x.y *)
  fun wire_match src_wire dest_wire = 
    let 
        val src_toks =  str src_wire |> String.tokens (fn s => s = #".") (* not sure if this will work *)
        val dest_toks = str dest_wire |> String.tokens (fn s => s = #".") (* not sure if this will work *)
        fun chk_tok t1 t2 = (t1 = t2)
        fun match (st::sts) (dt::dts) = chk_tok st dt andalso match sts dts 
          | match _ [] = true
          | match _ _ = false
    in 
       match src_toks dest_toks 
    end;


end; (* struct BasicStrWireItem *)

structure BasicStrWire :> BASIC_WIRE = BasicWireFun (structure BWI = BasicStrWireItem);

(* FIXME: move into Wire structure?? *)
infixr 4 <:
fun op <: (a,b) = BasicStrWire.wire_match b a;
(* is this right a is subtype of b??? 

*)


