signature WIRE_ITEMS = 
sig
  include NAMER;
  
  (* new stuff *)
  val default_wire : name 
  val wire_match : name -> name -> bool (* is wire order also required? *)
  val of_string : string -> name
  val string_of : name -> string
end;


signature BASIC_WIRE = 
sig
  include WIRE_ITEMS;

  type wset (* = NSet.T *)

  structure NSet : NAME_SET (* Wire set *)
   sharing type NSet.T = wset
   sharing type NSet.name = name

  val sub_wires : name -> wset -> wset; (* should be derivable from wire_match *)
  val wset_sub_wires : wset -> wset -> wset; (* subwires of a set of wires *)
  val wire_set_match : wset -> wset -> bool

end;

functor BasicWireFun (structure WI : WIRE_ITEMS) : BASIC_WIRE =
struct
  structure WI = WI;
  open WI;
 
  structure WSet = NameFun( structure Namer = WI 
                              val default_name = WI.default_wire); 

  structure NSet = WSet.NSet;

  type wset = NSet.T;

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

end; (* functor BasicWireFun *)

structure BasicStrWireItem : WIRE_ITEMS =
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

structure BWire :> BASIC_WIRE = BasicWireFun (structure WI = BasicStrWireItem);

(*
infixr 4 <:
fun op <: (a,b) = BWire.wire_match b a;
*)
