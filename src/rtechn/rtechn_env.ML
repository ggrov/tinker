(* Environment for reasoning technique  *)

(* tactic details stored in context *)
structure TacticTab =
struct

 structure Data = Theory_Data(struct 
    type T = (Thm.thm list -> Proof.context -> tactic) StrName.NTab.T
    val empty =  StrName.NTab.empty;
    val extend = I;
    fun merge (m1,_) = m1; (* or fail? *)
  end);

 exception undefined_strat_exp of string;

 val get_all_tactics = Data.get;

 fun get_tactic th name =
    case StrName.NTab.lookup (Data.get th) name of 
      NONE => raise undefined_strat_exp name
    | SOME v => v;

 (* note: no failure if trying to add same tactic twice *)
 fun try_ins el tab = case StrName.NTab.try_ins el tab of NONE => tab | SOME tab' => tab'
 val add_tactic = Data.map o try_ins;
 val add_tactic_list =  Data.map o (fold try_ins);

end; (* structure *)


structure RTechnEnv = 
struct
  val idtac = ("idtac",K (K (Seq.single:tactic)));
  val atac = ("atac",K (K (atac 1)));
  val notac = ("no_tac",K (K no_tac));


  val setup = 
    TacticTab.add_tactic_list [idtac,atac,notac];

end; (* struct *)


