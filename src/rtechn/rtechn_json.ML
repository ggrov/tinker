(* Reasoning technique independent of graph  *)

signature RTECHN_JSON = 
sig
  val rtechn_to_json : RTechn.T -> Json.json
  val rtechn_from_json : Json.json -> RTechn.T
end;


(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *) 
structure RTechnJSON (* : RTECHN_JSON *)
= struct

(* Json representation (revised by LYH):

  tac_assm := 
   { type : string,
     args : null | [string]

  atomic := 
    { type : string (Rule | ERule | FRUle | Subst | SubstAsm | Tactic)
      class : string | null
      rules : [string] | null
      tac_detail : null | tac_assm
    }

  rtechn := {
    name : string
    appf : string (HGraph | Merge | Identity | Or | Try) | atomic
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

  fun tac_assms_to_json TNoAsm = mk_object [("type", String "TNoAsm"), ("args", Null)]
  | tac_assms_to_json TAllAsm = mk_object [("type", String "TAllAsm"), ("args", Null)]
  | tac_assms_to_json (TClass nset) =  mk_object [("type", String "TClass"), ("args", StrNameNSet_to_json nset)]
  
  fun tac_assms_from_json (Object jobj) = 
    let 
      val (String typStr) = get jobj "type";
      val args = get jobj "args";
      val typList = [("TNoAsm", (1 : int)), ("TAllAsm",2) ,("TClass", 3)];
    in
      get_el_from_list typStr typList 
      |> snd
      |> (fn x => (case x of 1 => TNoAsm
                           | 2 => TAllAsm
                           | 3 => TClass (StrNameNSet_from_json args)))
    end
    | tac_assms_from_json _ = raise EXP_PARSING_JSON "Not a Json object type."

  fun atomic_to_json (Rule rules) = mk_object [("type", String "Rule"), ("rules",  StrNameNSet_to_json rules), ("class", Null), ("tac_details", Null)]
  | atomic_to_json (ERule (class, rules)) = mk_object [("type", String "ERule"),  ("rules",  StrNameNSet_to_json rules), ("class", String class), ("tac_details", Null)]
  | atomic_to_json (FRule (class, rules)) = mk_object [("type", String "FRule"), ("rules",  StrNameNSet_to_json rules), ("class", String class), ("tac_details", Null)]
  | atomic_to_json (Subst rules) = mk_object [("type", String "Subst"), ("rules",  StrNameNSet_to_json rules)]
  | atomic_to_json (SubstAsm (class, rules)) = mk_object [("type", String "SubstAsm"),("rules",  StrNameNSet_to_json rules), ("class", String class), ("tac_details", Null)]
  | atomic_to_json (Tactic (tac, class)) = mk_object [("type", String "Tactic"), ("rules", Null), ("class", String class), ("tac_details", tac_assms_to_json tac)]
 
  fun atomic_from_json (Object jobj) = 
    let 
      val (String typStr) = get jobj "type";
      val rules = get jobj "rules";
      val class = get jobj "class";
      val tac = get jobj "tac_details";
      val typList = [("Rule", (1 : int)), ("ERule",2), ("FRule", 3), ("Subst", 4), ("SubstAsm", 5), ("Tactic", 6)]
    in
      get_el_from_list typStr typList 
      |> snd
      |> (fn x => case x of 1 => Rule (StrNameNSet_from_json rules)
                           | 2 => let val (String str) = class in ERule (str,(StrNameNSet_from_json rules)) end
                           | 3 => let val (String str) = class in FRule (str,(StrNameNSet_from_json rules)) end
                           | 4 => Subst (StrNameNSet_from_json rules)
                           | 5 => let val (String str) = class in SubstAsm (str,(StrNameNSet_from_json rules)) end
                           | 6 => let val (String str) = class in Tactic ((tac_assms_from_json tac), str) end
          )
    end
  | atomic_from_json _ = raise EXP_PARSING_JSON "Not a Json object type."

(* TODO: not yet complete *)
  fun appfn_to_json (Appf atomic) = mk_object [("type", String "Appf"), ("atomic", atomic_to_json atomic)]
  | appfn_to_json Identify = mk_object [("type",String "Identity")]
  | appfn_to_json _ = raise EXP_PARSING_JSON "Not yet supported type in appfn"

 
  fun appfn_from_json (Object jobj) = 
    let 
      val (String typStr) = get jobj "type";
      val atomic = get jobj "atomic";
      val typList = [("Appf", (1 : int)), ("HGraph0",2), ("HGraph1",3), ("Merge", 4), ("Identity", 5), ("Or", 6), ("Try", 7)]
    in
      get_el_from_list typStr typList 
      |> snd
      |> (fn x => case x of 1 => Appf (atomic_from_json atomic)
                          (*| 2 => HGraph NONE
                          | 3 => HGraph NONE
                          | 4 => Merge
                          | 5 => Identity
                          | 6 => Or
                          | 7 => Try*)
                          | _ => raise EXP_PARSING_JSON "Not yet supported type in appfn"
          )
    end
  | appfn_from_json _ = raise EXP_PARSING_JSON "Not a Json object type."

  fun rtechn_to_json rtechn = 
    let 
      val name_obj = mk_object [("type", String "string"), ("arg", String (get_name rtechn))];
      val appf_obj = mk_object [("type", String "appfn"), ("appfn", appfn_to_json (get_appf rtechn))]
    in
      mk_object [("name", String (get_name rtechn)), ("appf", appf_obj)]
    end
  
  fun rtechn_from_json  (Object jobj) =
    let 
      val appf = get jobj "appf";
      val (String name) = get jobj "name";
    in
      RTechn.id
      |> RTechn.set_name name
      |> RTechn.set_appf (appfn_from_json appf)
    end
    | rtechn_from_json _ = raise EXP_PARSING_JSON "Not a Json array type."

  
end(*end of local open*)

end; (* struct *)


