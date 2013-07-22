(* Reasoning technique independent of graph  *)

signature RTECHN_JSON = 
sig
  val rtechn_to_json : RTechn.T -> Json.json
  val rtechn_from_json : Json.json -> RTechn.T
end;


(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *) 
structure RTechnJSON (* : RTECHN_JSON *)
= struct

(* Json representation ( a flat version, remove redendunt info):

  tac_assm := 
   { tac_assm_type : TNoAsm | TAllAsm | TClass
     asm_list : [string] | null

  atomic := 
    { atomic_type : string (Rule | ERule | FRUle | Subst | SubstAsm | Tactic)
      class : string | null
      rules : [string] | null
      tac_detail : null | tac_assm
    }
  
  rtechn := {
    rt_name : string
    appf_type : string (HGraph | Merge | Identity | Or | Try | Appf)
    atomic: atomic | null
    type : "RT"
  }

*)
local open RTechn Json in
(*
  Json representation construction
  JsonUnit =  String of string | Int of int | Real of real | Bool of bool | Null
  JsonRep = {(type : name), (arglist : Null | [JsonUnit | JsonRep])}
*)
  exception EXP_PARSING_JSON of string;
 
  fun get_el_from_list str strl =  
    List.filter (fn (x,_) => case (String.compare (str, x)) 
                              of EQUAL => true 
                              | _ => false) 
                strl 
    |> hd
    handle _ => raise EXP_PARSING_JSON ("Unknown type constructor \""^str^"\"")
  
  fun get obj (prop : string) =
    Json.get obj prop
    handle Json.notfound_exn prop =>
      raise EXP_PARSING_JSON ("Missing property \""^prop^"\"");

  fun json_type_check json typStr = 
    let val str = case (get json "type") of (String s) => s  in
     case (String.compare (str,typStr)) 
      of EQUAL => typStr
      | _ =>  raise EXP_PARSING_JSON ("Mismatching type: expect \""^typStr^"\" but get \""^str^"\"")
    end

  fun STRN_NSet_to_json nset =  Array(map String (map StrName.string_of_name (StrName.NSet.list_of (nset))));

  fun StrN_NSet_from_json (Array l) = map (fn (String el) => el) l |>StrName.NSet.of_list                          
    | StrN_NSet_from_json _ = raise EXP_PARSING_JSON "Not a Json object type."

  fun CNSet_to_json nset =  Array(map String (map C.string_of_name (C.NSet.list_of (nset))));

  fun CNSet_from_json (Array l) = map (fn (String el) => el) l |> map RT.mk |>C.NSet.of_list                          
    | CNSet_from_json _ = raise EXP_PARSING_JSON "Not a Json object type."


  fun tac_assms_to_json TNoAsm = mk_object [("tac_assm_type", String "TNoAsm")]
  | tac_assms_to_json TAllAsm = mk_object [("tac_assm_type", String "TAllAsm")]
  | tac_assms_to_json (TClass nset) =  mk_object [("tac_assm_type", String "TClass"), 
                                                  ("asm_list", CNSet_to_json nset)]
  
  fun tac_assms_from_json (Object jobj) = 
    let 
      val (String typStr) = get jobj "tac_assm_type";
      val typList = [("TNoAsm", (1 : int)), ("TAllAsm",2) ,("TClass", 3)];
    in
      get_el_from_list typStr typList 
      |> snd
      |> (fn x => (case x of 1 => TNoAsm
                           | 2 => TAllAsm
                           | 3 => TClass (CNSet_from_json ( get jobj "asm_list"))))
    end
    | tac_assms_from_json _ = raise EXP_PARSING_JSON "Not a Json object type."

  fun atomic_to_json (Rule rules) = mk_object [("atomic_type", String "Rule"), ("rules",  STRN_NSet_to_json rules)]
  | atomic_to_json (ERule rules) = mk_object [("atomic_type", String "ERule"), ("rules",  STRN_NSet_to_json rules)]
  | atomic_to_json (FRule (class, rules)) = mk_object [("atomic_type", String "FRule"),
                                                       ("rules",  STRN_NSet_to_json rules),
                                                       ("class", String (C.string_of_name class))]
  | atomic_to_json (Subst rules) = mk_object [("atomic_type", String "Subst"), ("rules",  STRN_NSet_to_json rules)]
  | atomic_to_json (SubstAsm (class, rules)) = mk_object [("atomic_type", String "SubstAsm"),
                                                          ("rules",  STRN_NSet_to_json rules), 
                                                          ("class", String (C.string_of_name class))]
  | atomic_to_json (Tactic (tac, name)) = mk_object [("atomic_type", String "Tactic"), 
                                                     ("class", String (name)), 
                                                     ("tac_details", tac_assms_to_json tac)]
 
  fun atomic_from_json (Object jobj) = 
    let 
      val (String typStr) = get jobj "atomic_type";
      val typList = [("Rule", (1 : int)), ("ERule",2), ("FRule", 3), ("Subst", 4), ("SubstAsm", 5), ("Tactic", 6)]
    in
      get_el_from_list typStr typList 
      |> snd
      |> (fn x => case x of 1 => Rule (StrN_NSet_from_json (get jobj "rules"))
                           | 2 => ERule (StrN_NSet_from_json (get jobj "rules"))
                           | 3 => let val (String str) = (get jobj "class") in
                                    FRule (C.mk str,(StrN_NSet_from_json (get jobj "rules"))) end
                           | 4 => Subst (StrN_NSet_from_json (get jobj "rules"))
                           | 5 => let val (String str) = (get jobj "class") in
                                    SubstAsm (C.mk str,(StrN_NSet_from_json (get jobj "rules"))) end
                           | 6 => let val (String str) = (get jobj "class") in 
                                    Tactic ((tac_assms_from_json (get jobj "tac_details")), str) end
          )
    end
  | atomic_from_json _ = raise EXP_PARSING_JSON "Not a Json object type."

(* TODO: not yet complete *)
  fun appfn_to_json (Appf atomic) =  mk_object[("appfn_type", String "Appf"), ("atomic", atomic_to_json atomic)]
  | appfn_to_json (HGraph _) = mk_object[("appfn_type", String "HGraph")]
  | appfn_to_json Identify = mk_object[("appfn_type", String "Identity")]
  | appfn_to_json Merge = mk_object[("appfn_type", String "Merge")]
  | appfn_to_json Or = mk_object[("appfn_type", String "Or")]
 (* | appfn_to_json Try = mk_object [("type", String "Try")]*)
  | appfn_to_json _ = raise EXP_PARSING_JSON "Not yet supported type in appfn"

 
  fun appfn_from_json (Object jobj) = 
    let 
      val (String typStr) = get jobj "appfn_type";
      val typList = [("Appf", (1 : int)), ("HGraph",2), ("HGraph1",3), ("Merge", 4), ("Identity", 5), ("Or", 6), ("Try", 7)]
    in
      get_el_from_list typStr typList 
      |> snd
      |> (fn x => case x of 1 => Appf (atomic_from_json (get jobj "atomic"))
                          (*| 3 => HGraph NONE*)
                          | 2 => HGraph NONE
                          | 4 => Merge
                          | 5 => Identity
                          | 6 => Or
                          (*| 7 => Try*)
                          | _ => raise EXP_PARSING_JSON "Not yet supported type in appfn"
          )
    end
  | appfn_from_json _ = raise EXP_PARSING_JSON "Not a Json object type."

  fun rtechn_to_json rtechn = 
    let 
      val appf_obj =  appfn_to_json (get_appf rtechn)
    in
      mk_object [("rt_name", String (RT.string_of_name (get_name rtechn))), ("appf", appf_obj), ("type", Json.String "RT")]
    end
  
  fun rtechn_from_json' (Object jobj) =
    let 
      val appf = get jobj "appf";
      val (String name) = get jobj "rt_name";
    in
      RTechn.id
      |> RTechn.set_name (RT.mk name)
      |> RTechn.set_appf (appfn_from_json appf)
    end
    | rtechn_from_json' _ = raise EXP_PARSING_JSON "Not a Json array type."
  
  fun of_str str = 
    let 
      val splitstr =  String.tokens (member (op =) [#" "]);
      val l = splitstr str;
    in
      case hd l 
        of "rule"  => 
          RTechn.id
          |> RTechn.set_name (RT.mk str)
          |> RTechn.set_atomic_appf (RTechn.Rule (StrName.NSet.of_list (tl l)))
        |  "erule" =>
          RTechn.id
          |> RTechn.set_name (RT.mk str)
          |> RTechn.set_atomic_appf (RTechn.ERule (StrName.NSet.of_list (tl l)))
        |  "subst" => 
          RTechn.id
          |> RTechn.set_name (RT.mk str)
          |> RTechn.set_atomic_appf (RTechn.Subst (StrName.NSet.of_list (tl l)))
        | "frule" =>
          RTechn.id
          |> RTechn.set_name (RT.mk str)
          |> RTechn.set_atomic_appf (RTechn.FRule (C.mk "any", StrName.NSet.of_list (tl l)))
        | "substasm" =>
          RTechn.id
          |> RTechn.set_name (RT.mk str)
          |> RTechn.set_atomic_appf (RTechn.SubstAsm (C.mk "any", StrName.NSet.of_list (tl l)))
        |   _      =>            
          RTechn.id
          |> RTechn.set_name (RT.mk str)
          |> RTechn.set_atomic_appf (RTechn.Tactic (RTechn.TAllAsm,(str)))
    end;

  fun rtechn_from_json (Object jobj) =
    let 
      val (String rtechn) = get jobj "rt_name";
      (*val _ = tracing rtechn *)
    in
      of_str rtechn
    end
    | rtechn_from_json _ = raise EXP_PARSING_JSON "Not a Json array type."

  
end(*end of local open*)

end; (* struct *)


