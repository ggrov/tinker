(* Reasoning technique independent of graph  *)

signature RTECHN_JSON = 
sig
  type T
  val rtechn_to_json : RTechn.T -> Json.json
  val rtechn_from_json : Json.json -> RTechn.T
end;


(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *) 
structure RTechnJSON : RTECHN_JSON 
= struct

  (*TODO: make them as sharing types to gurantee consistency*)
  datatype EvalData = EData of string

  datatype tac_assms = TNoAsm | TAllAsm | TClass of StrName.NSet.T

  datatype atomic =
     Rule of StrName.NSet.T (* rules used - what about with wire? *)
   | ERule of StrName.name * StrName.NSet.T (* wire + rules used *)
   | FRule of StrName.name * StrName.NSet.T (* wire + rules used *)
   | Subst of StrName.NSet.T (* separate rule vs bwire? *)
   | SubstAsm of StrName.name * StrName.NSet.T (* bwre and rules - sep. rule vs bwire *)
   | Tactic of tac_assms * string (* bwires as facts + name of stactic *)

  datatype appfn = Appf of atomic
                 | HGraph of EvalData option
                 | Merge
                 | Identity
                 | Or (* of EvalData option *)
                 | Try (* of EvalData option *)

  datatype T =
    RTechn of {
   		name : string,
  	 	appf : appfn}

(* Json representation (revised by LYH):
  {
    type : string,  
    {
      name : string, 
      appf : {
              type : (Appf | HGraph | Merge | Identity | Or | Try)],
              (
                {
                  Appf : {
                           type : (Rule | ERule | FRUle | Subst | SubstAsm | Tactic),
                           args : [list of arg]
                         } 
                }
                | {HGraph: null | string }
                | {Merge: null}
                | {Identity: null}
                | {Or: null}
                | {Try : null}
              )
            }
   }
*)
local open RTechn Json in
(*
  Json representation construction
  JsonUnit =  String of string | Int of int | Real of real | Bool of bool | Null
  JsonRep = {(type : name), (arglist : Null | [JsonUnit | JsonRep])}
*)
  exception EXP_PARSING_JSON of string;
 
  fun get_el_from_list str strl =  List.filter (fn (x,_) => case (String.compare (str, x)) of EQUAL => true | _ => false) strl |> hd
                                   handle _ => raise EXP_PARSING_JSON ("Unknown type constructor \""^str^"\"")
  
  fun get obj (prop : string) =
    Json.get obj prop
    handle Json.notfound_exn prop =>
      raise EXP_PARSING_JSON ("Missing property \""^prop^"\"");

  fun json_type_check json typStr = 
    let val str = case (get json "type") of (String s) => s  in
     case (String.compare (str,typStr)) of EQUAL => typStr
                                     | _ =>  raise EXP_PARSING_JSON ("Mismatching type: expect \""^typStr^"\" but get \""^str^"\"")
    end

  fun StrNameNSet_to_json nset = mk_object [("type", String "StrName.NSet"), ("arglist", Array(map String (StrName.NSet.list_of nset)))];
  fun StrNameNSet_from_json (Object jobj) = 
    let 
      val _ = json_type_check jobj "StrName.NSet";
      val (Array list) = get jobj "arglist"
    in
      map (fn (String el) => el) list |> StrName.NSet.of_list                          
    end
    | StrNameNSet_from_json _ = raise EXP_PARSING_JSON "Not a Json object type."

  fun tac_assms_to_json TNoAsm = mk_object [("type", String "TNoAsm"), ("arglist", Null)]
  | tac_assms_to_json TAllAsm = mk_object [("type", String "TAllAsm"), ("arglist", Null)]
  | tac_assms_to_json (TClass nset) =  mk_object [("type", String "TClass"), ("arglist", Array[StrNameNSet_to_json nset])]
  
  fun tac_assms_from_json (Object jobj) = 
    let 
      val (String typStr) = get jobj "type";
      val (Array list) = get jobj "arglist";
      val typList = [("TNoAsm", (1 : int)), ("TAllAsm",2) ,("TClass", 3)];
    in
      get_el_from_list typStr typList 
      |> snd
      |> (fn x => (case x of 1 => TNoAsm
                           | 2 => TAllAsm
                           | 3 => TClass (StrNameNSet_from_json (hd list))))
    end
    | tac_assms_from_json _ = raise EXP_PARSING_JSON "Not a Json object type."

  fun atomic_to_json (Rule arg) = mk_object [("type", String "Rule"), ("arglist",  Array[StrNameNSet_to_json arg])]
  | atomic_to_json (ERule (arg1, arg2)) = mk_object [("type", String "ERule"), ("arglist", Array [String arg1, StrNameNSet_to_json arg2])]
  | atomic_to_json (FRule (arg1, arg2)) = mk_object [("type", String "FRule"), ("arglist", Array [String arg1, StrNameNSet_to_json arg2])]
  | atomic_to_json (Subst arg) = mk_object [("type", String "Subst"), ("arglist", Array [StrNameNSet_to_json arg])]
  | atomic_to_json (SubstAsm (arg1, arg2)) = mk_object [("type", String "SubstAsm"), ("arglist", Array [String arg1, StrNameNSet_to_json arg2])]
  | atomic_to_json (Tactic (arg1, arg2)) = mk_object [("type", String "Tactic"), ("arglist", Array [tac_assms_to_json arg1, String arg2])]
 
  fun atomic_from_json (Object jobj) = 
    let 
      val (String typStr) = get jobj "type";
      val (Array list) = get jobj "arglist";
      val typList = [("Rule", (1 : int)), ("ERule",2), ("FRule", 3), ("Subst", 4), ("SubstAsm", 5), ("Tactic", 6)]
    in
      get_el_from_list typStr typList 
      |> snd
      |> (fn x => case x of 1 => Rule (StrNameNSet_from_json (hd list))
                           | 2 => let val (String str) = hd list in ERule (str,(StrNameNSet_from_json (hd (tl list)))) end
                           | 3 => let val (String str) = hd list in FRule (str,(StrNameNSet_from_json (hd (tl list)))) end
                           | 4 => Subst (StrNameNSet_from_json (hd list))
                           | 5 => let val (String str) = hd list in SubstAsm (str,(StrNameNSet_from_json (hd (tl list)))) end
                           | 6 => let val (String str) = hd (tl list) in Tactic ((tac_assms_from_json (hd list)), str) end
          )
    end
  | atomic_from_json _ = raise EXP_PARSING_JSON "Not a Json object type."

(* TODO: not yet complete *)
  fun appfn_to_json (Appf arg) = mk_object [("type", String "Appf"), ("arglist",  Array[atomic_to_json arg])]
  | appfn_to_json (HGraph (SOME arg)) = mk_object [("type", String "HGraph0"), ("arglist", Null)]
  | appfn_to_json (HGraph NONE) = mk_object [("type", String "HGraph1"), ("arglist", Null)]
  | appfn_to_json Merge = mk_object [("type", String "Merge"), ("arglist", Null)]
  | appfn_to_json Identity = mk_object [("type", String "Identity"), ("arglist", Null)]
  | appfn_to_json Or = mk_object [("type", String "Or"), ("arglist", Null)]
  | appfn_to_json Try = mk_object [("type", String "Try"), ("arglist", Null)]
 
  fun appfn_from_json (Object jobj) = 
    let 
      val (String typStr) = get jobj "type";
      val (Array list) = get jobj "arglist";
      val typList = [("Appf", (1 : int)), ("HGraph0",2), ("HGraph1",3), ("Merge", 4), ("Identity", 5), ("Or", 6), ("Try", 7)]
    in
      get_el_from_list typStr typList 
      |> snd
      |> (fn x => case x of 1 => Appf (atomic_from_json (hd list))
                          | 2 => HGraph NONE(*need to update*)
                          | 3 => HGraph NONE
                          | 4 => Merge
                          | 5 => Identity
                          | 6 => Or
                          | 7 => Try
          )
    end
  | appfn_from_json _ = raise EXP_PARSING_JSON "Not a Json object type."

  fun rtechn_to_json rtechn = 
    let 
      val name_obj = mk_object [("type", String "string"), ("arglist", Array[String (get_name rtechn)])];
      val appf_obj = mk_object [("type", String "appfn"), ("arglist", Array[appfn_to_json (get_appf rtechn)])]
    in
      Array [name_obj, appf_obj]
    end
  
  fun rtechn_from_json (Array recordlist) =
    let 
      val (Object name_obj) = hd recordlist;
      val (Array strl) = get name_obj "arglist";
      val (String str) = hd strl;
      val appf_obj = hd (tl recordlist)
    in
      RTechn {name = str, appf = (appfn_from_json appf_obj)} (*TODO: fail to construct, need discussion*)
    end
    | rtechn_from_json _ = raise EXP_PARSING_JSON "Not a Json array type."

  
end(*end of local open*)

end; (* struct *)


