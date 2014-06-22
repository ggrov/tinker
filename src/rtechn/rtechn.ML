signature RTECHN = 
sig

(*
 example Atomic 
  rule,[[exI]]
  frule[[exI],[X,Y]]
  erule(exE,X,Y)
  simp[["add","a","b"]]
  auto[["simp add", "a"],["intro","d"]]

Nested
  use args as input output for variable binding
*)

  type arg_typ = string list list

  datatype T = Atomic of { name : string, args : arg_typ}
             | Nested of { name : string, args : arg_typ, is_or : bool}
             | Identity 

  exception rtechn_exp of string * T;

  val get_name : T -> string 
  val get_args : T -> arg_typ  (* raises rtechn_exp *)
  val get_is_or :T ->  bool (* raises rtechn_exp *)

  val update_name : (string -> string) -> T -> T 
  val update_args : (arg_typ -> arg_typ) -> T -> T  (* raises rtechn_exp *)
  val update_is_or : (bool -> bool) -> T -> T  (* raises rtechn_exp *)

  val set_name : string -> T -> T 
  val set_args : arg_typ -> T -> T  (* raises rtechn_exp *)
  val set_is_or : bool -> T -> T  (* raises rtechn_exp *)

  val identity : T
  (* val fail : T *)

  val is_atomic : T -> bool
  val is_nested : T -> bool
  val is_identity : T -> bool
  val is_or : T -> bool option
  val is_or' : T -> bool (* false if not nested *)



  (* pretty printing *)
  val pretty : T -> Pretty.T

end;


(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *) 
structure RTechn  : RTECHN 
= struct
  type arg_typ = string list list

  datatype T = Atomic of { name : string, args : arg_typ}
             | Nested of { name : string, args : arg_typ, is_or : bool}
             | Identity  (* TODO: should this be in graph only? *)

  exception rtechn_exp of string * T;

  fun get_name (Atomic {name,...}) = name
   |  get_name (Nested {name,...}) = name
   |  get_name Identity = "identity"

  fun get_args (Atomic {args,...}) = args
   |  get_args (Nested {args,...}) = args
   |  get_args Identity = raise rtechn_exp ("identity rtechn",Identity);

  fun get_is_or (Nested {is_or,...}) = is_or
   |  get_is_or T = raise rtechn_exp ("not nested rtechn",T);

  fun update_name f (Atomic rep) = 
      Atomic { name = f (#name rep), args = #args rep}
   | update_name f (Nested rep) = 
      Nested { name = f (#name rep), args = #args rep, is_or = #is_or rep}
   | update_name _ Identity = Identity

  fun update_args  f (Atomic rep) = 
        Atomic { name = (#name rep), args = f (#args rep)}
   |  update_args  f (Nested rep) = 
       Nested { name = #name rep, args = f (#args rep), is_or = #is_or rep}
   | update_args  _ Identity =  raise rtechn_exp ("identity rtechn",Identity);

 fun update_is_or f (Nested rep) = 
      Nested { name =  (#name rep), args = #args rep, is_or = f (#is_or rep)}
  | update_is_or _ T = 
     raise rtechn_exp ("not nested rtechn",T);

  val set_name = update_name o K;
  val set_args = update_args o K;
  val set_is_or = update_is_or o K;

  val identity = Identity;

  (* val fail : T *)

  fun is_atomic (Atomic _) = true
   |  is_atomic _ = false;

  fun is_nested (Nested _) = true
   |  is_nested _ = false;

  fun is_identity Identity = true
   |  is_identity _ = false;

  fun is_or (Nested {is_or, ...}) = SOME is_or
   |  is_or _ = NONE

  fun is_or' T = 
    case is_or T of 
      SOME v => v
    | NONE => false;

  (* pretty printing [fixme] *)
 fun pretty (Atomic {name,...}) = Pretty.str name
   | pretty (Nested {name,...}) = Pretty.str name
   | pretty Identity = Pretty.str "identity"

end; (* struct *)



