signature BWIRE =
sig
  type bwire
  type name 
  sharing type bwire = name

  (* from Namer *)
  val suc : name -> name
  val pred : name -> name option
  val ord : name * name -> order
  val eq : name * name -> bool
  val pretty : name -> Pretty.T

  val default_wire : name 
  val wire_match : name -> name -> bool (* is wire order also required? *)
  val of_string : string -> name
  val string_of : name -> string

end (* sig *)

(* maybe have a wire name and a table name -> BWire?? *)

structure BWire =
struct

  (* invariant:
      if two names are equal then it is the same wire!!
      - hmmm. should really check features
      - no feature can be contradictory (including pos vs neg) *)
  datatype bwire = BWire of { name : SStrName.name, 
                              pos : F.NSet.T,
                              neg : F.NSet.T 
                            }

  fun get_name (BWire rep) = #name rep;
  fun get_pos (BWire rep) = #pos rep;
  fun get_neg (BWire rep) = #neg rep;

  fun update_name f (BWire rep) = 
    BWire {name = f (#name rep), pos = #pos rep,neg = #neg rep }
  fun update_pos f (BWire rep) = 
    BWire {name = #name rep, pos = f (#pos rep),neg = #neg rep }
  fun update_neg f (BWire rep) = 
    BWire {name = #name rep, pos = #pos rep,neg = f (#neg rep) }

  val set_name = update_name o K;
  val set_pos = update_pos o K;
  val set_neg = update_neg o K;

  val default_wire =
    BWire {name = SStrName.default_name,
          pos = F.NSet.empty,
          neg = F.NSet.empty};

(*
  fun match w rst g = 
    (* all positive features matches *)
    F.NSet.forall (fn f => Feature.match f rst g) (get_pos w) 
     andalso 
    (* and no negative features matches *)
    not(F.NSet.exists (fn f => Feature.match f rst g) (get_neg w));
*)

  (* fixme: is this correct? maybe Feature.sub_feature_of?? *)
(*
  fun sub_pos_one th p = F.NSet.exists (Feature.subfeature_of th p)

  fun sub_pos th ps1 ps2 = F.NSet.forall (fn p => sub_pos_one th p ps2) ps1;

  fun sub_wire th w1 w2 = (* fixme: what does this mean for negative features? *)
    sub_pos th (get_pos w1) (get_pos w2);
*)
  (* for name set *)
  type name = bwire;
  fun suc f = set_name (SStrName.Namer.suc (get_name f)) f
  fun pred f = case (SStrName.Namer.pred (get_name f)) of
                 NONE => NONE
                | SOME n => SOME (set_name n f);
  fun ord (f1,f2) = SStrName.Namer.ord (get_name f1,get_name f2);
  fun eq (f1,f2) = (ord(f1,f2) = EQUAL);
  fun pretty bw = Pretty.block (* fixme: comma between features *)
                   ([Pretty.str (SStrName.dest (get_name bw)), Pretty.str ": {"]
                   @ (map Feature.pretty (get_pos bw |> F.NSet.list_of))
                   @ [Pretty.str "}"]);
end

structure W = NameFun(structure Namer = BWire val default_name = BWire.default_wire);
structure WTab = BasicNameTabFun(structure NSet = W.NSet ; structure Namer = BWire);
type gmap = GFact.NSet.T WTab.T;

