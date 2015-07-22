functor SimpleGoalType_Fun(structure Prover : PROVER  
                    val struct_name : string) : BASIC_GOALTYPE =
struct
  local open LoggingHandler in

  structure Prover = Prover;
  type T = string
  datatype gnode = G of {name: string, pretty: Pretty.T} (* or with term? *)
  type data  = unit;

  exception gt_exp of string
  val default = "any";
  val default_gnode = G {name = "?", pretty = Pretty.str "?"};
  val default_data = ();

  val ord = String.compare;
  fun eq (t1,t2) = case ord(t1,t2) of EQUAL => true | _ => false;

  fun goal_name (G {name, ...}) = name;
  fun goal_pretty (G {pretty, ...}) = pretty

  fun gnode_ord (g1, g2) = String.compare (goal_name g1, goal_name g2);
  fun gnode_eq (g1,g2) = case gnode_ord(g1,g2) of EQUAL => true | _ => false;

  fun gnode_to_json g = 
   Json.mk_object[
    ("name", Json.String (goal_name g)),
    ("goal", Json.String (Pretty.string_of (goal_pretty g) (*|> UnicodeHelper.encode*)))];

  fun gnode_from_json (Json.Object obj) = 
    G {name = JsonInputUtils.get_string obj "name", 
       pretty = Pretty.str (JsonInputUtils.get_string obj "goal" (*|> UnicodeHelper.decode*))}
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
  val pretty_gnode = Pretty.str o goal_name;
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


    fun lift_list _ _ [] = false
     |  lift_list pn data (x::xs) =
          ((case x of 
           "any"       => true (* default *)
           | "label"      => true
           |  exp         =>  GoalTyp_ML_Exec.eval_ml 
                                exp (Prover.get_pnode_ctxt pn) 
                                (Prover.get_pnode_hyps pn) 
                                (Prover.get_pnode_concl pn)  
                              |> debug_trace x)
        (*handle _ => false*));

   fun lift' pn (data, str) = lift_list pn data [str] (*splitstr str*)
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

  fun lift pn = G {name = (Prover.get_pnode_name pn), pretty = Prover.pretty_goal pn}

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
