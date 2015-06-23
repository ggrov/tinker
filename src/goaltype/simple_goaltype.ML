functor SimpleGoalType_Fun(structure Prover : PROVER  
                    val struct_name : string) : BASIC_GOALTYPE =
struct
  local open LoggingHandler in

  structure Prover = Prover;
  type T = string
  type gnode = string (* or with term? *)
  type data  = unit;

  exception gt_exp of string
  val default = "any";
  val default_gnode = "?";
  val default_data = ();

  val ord = String.compare;
  fun eq (t1,t2) = case ord(t1,t2) of EQUAL => true | _ => false;

  val gnode_ord = String.compare;
  fun gnode_eq (g1,g2) = case gnode_ord(g1,g2) of EQUAL => true | _ => false;

  val goal_name = I;

  val gnode_to_json = Json.String;
  fun gnode_from_json (Json.String str) = str
  | gnode_from_json _ = raise gt_exp "gnode_from_json: ill-formed json structure"

  fun data_to_json _ = Json.String "";
  fun data_from_json _ = ()

(*
  val to_json = Json.String;
  fun from_json (Json.String str) = str;
*)
  fun to_json str = Json.String str

  fun from_json (Json.String str) = str
  | from_json _ = raise gt_exp "from_json: ill-formed json structure"

  fun pretty_data _ = Pretty.str "";
  val pretty_gnode = Pretty.str;
  val pretty = Pretty.str;

(**************************************************************
    ML String parsing 
**************************************************************)
  type gtyp = Prover.context -> Prover.term list -> Prover.term -> bool
  structure GoalTyp_ML_Exec = 
    ML_Exec_Func (val exec_str = Prover.exec_str 
                  type ret = gtyp 
                  val struct_name = struct_name ^".GoalTyp_ML_Exec");

    fun debug_trace str b = 
      if b then (logging "GOALTYPE" (str ^ " returns true !"); b) 
      else (logging "GOALTYPE" (str ^ " returns false !"); b);


(**************************************************************
    simple goaltype parsing 
**************************************************************)
     fun liftp pn pred = 
     if pred then  [(Prover.get_pnode_name pn)] else []; 
 
    val splitstr =  String.tokens (member (op =) [#" ",#",",#"(",#")",#"[",#"]"]);
    val split_args = String.tokens (member (op =) [#"|"]);

    fun lift_list _ _ [] = false
     |  lift_list pn data (x::xs) =
          ((case x of 
            "not"       => not (lift_list pn data xs) 
           | "or"        => exists I (map (lift_list pn data) (map split_args (xs))) |> debug_trace x
           | "any"       => true (* default *)
           | "anything"   => true (* default *)
           | "label"      => true
           |  exp         =>  GoalTyp_ML_Exec.eval_ml 
                                exp (Prover.get_pnode_ctxt pn) 
                                (Prover.get_pnode_hyps pn) 
                                (Prover.get_pnode_concl pn)  
                              |> debug_trace x)
        (*handle _ => false*));

   fun lift' pn (data, str) = lift_list pn data (splitstr str)
   (*handle _ => raise gt_exp "int lift'";*)

   fun init_lift (data,str) pn =
     let 
        val ls = String.tokens (fn c => c = #";") str
        val _ = logging "GOALTYPE" (("init goal " ^  (Prover.get_pnode_name pn) ^  " with goal type: " ^ str ))
    in 
     case ls of 
       [] => (logging "GOALTYPE" "warning; No goal types !"; [])
      | _ => ls |> map (fn x => lift' pn (data, x))
                |> forall I 
                |> liftp pn
   end
   (*handle _ => raise gt_exp "in init lift";*)

  (* assume gn is the name of pn *)
  fun check (data,str) (_,pn) = 
    case init_lift (data,str) pn of
     [] => false
    | _ => true;

  fun lift pn = (Prover.get_pnode_name pn)

  structure BasicSharing =
  struct
    type T = T
    type gnode = gnode
    type data = data
    type gtyp = gtyp
    structure Prover = Prover.Sharing
  end
  end (* local open *)
end(* struct *);
