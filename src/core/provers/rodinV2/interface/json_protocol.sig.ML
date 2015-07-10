(* This is the interface for json used by the communication between tinker and third party
 * provers. All third party prover may implement this interface to create specific protocol. 
 * This interface aim to simplify the creation/manipulation of json string. It is dependent on the JSON
 * interface from  http://www.json.org/.
 *
 * Between the communication of Tinker and Rodin
 * A command is the structure that carries the communication and instructions between two 
 * programs. As it is firstly implemented for Tinker plugin of Rodin platform, the command is 
 * suggested as string * ((string * string) list).
 * Example:  ["APPLY_TACTIC", [("NAME","CONJI")]]
       =    {"CMD":"APPLY_TACTIC","PARAMS":{"NAME":"CONJI"}}
 * Example:  ["NAME_ALL_OPEN_NODES", [("1","G1"),("2","G2"),("3","G3")]]
       =    {"CMD":"NAME_ALL_OPEN_NODES","PARAMS":{"1":"G1","2":"G2","3":"G3"}}
*)

signature JSONPROTOCOL =
sig
  (* Type that represent the command structure *)
  type command
  type tkey
  type tvalue

  val fromJson : string -> command
  val toJson : command -> string

  val getParam : command -> tkey -> tvalue

  val getParamKeys : command -> tkey list

  val getParamValues : command -> tvalue list

  val getParams : command -> (tkey * tvalue) list

  val getInstruction : command -> string

end
