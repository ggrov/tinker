theory full_wire_test                                          
imports      
  Main   
  "../../build/HOL_IsaP" (* needed for induction stuff *)  
 uses  
 "../goal_node.ML"  
 "../full_wire.ML"  
 "../features/term_fo_au.ML"                                                                                                                                  
begin





(* replace equal *)
ML{*

*}

ML{*
Sign.typ_equiv @{theory};

*}
ML{*

*}

consts a :: nat
       b :: "nat => nat"
       t :: "nat => nat => nat"
       c :: nat
       d :: "'a => 'a"
ML{*
val t1 = @{term "t (b x) 0"};
val t2 = @{term "t (b 0) 0"};

FirstOrderAU.get_one (t1,t2);

FirstOrderAU.generalise (t1,t2);

*}






(* 
wire: hyps |- goal
  - wire: between hyps/goal
  - hyps: props about the given goal
  - goal: props about current goal
new wire which only discuss relationship between other wires, e.g.
  embeds(goal,hyp)
  subterms(goal,hyp)
*)



(* 
    forward step:
      consumes: hyp wire
      produces: hyp wire
      - should really accept a function which updates the pplan given two facts
      - and returns list of new facts and new goals (unless there are different types of goals?)

    backward step:
      consumes: goal + given hyp wire(s)
      produces: goal 

    tactics (local and global assumptions): 
      consumes: goal 
      produces: goals
      wires: 1 inwire + 1 output 
*)


(* FIXME: combine is not a reasoning technique in the "standard way" *)

(* must easier if they were sets!!! *)





end



