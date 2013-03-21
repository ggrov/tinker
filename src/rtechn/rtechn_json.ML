(* Reasoning technique independent of graph  *)

signature RTECHN_JSON = 
sig
  val to_json : RTechn.T -> json
  val from_json : json -> RTechn.T
end;


(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *) 
structure RTechnJSON : RTECHN_JSON 
= struct

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
  		appf: appfn}

 (* Json representation: is this too flat?
   { name : string , 
     appf : { type : (appf | hgraph | merge | identity | or | try )
              atomic : null |
                  { type : string
                    arg1 : null | [string]
                    arg2 : null | [string]
                    tactic : null | string
                    tac_asm : null | string 
                    tac_asm_arg : [string] | null
                  }
              hgraph : null | string
*)

  fun to_json rtechn = 
    Json.empty_obj
    |> Json.update ("name",(Json.String (RTechn.get_name rtech)))
    |> Json.update ("type", Json.Null);


  fun from_json json = 
    RTechn.id
    |> RTechn.set_name (Json.get "name" json |> Json.string_of)

end; (* struct *)


