signature CONJ_GEN_DATA =
sig
   type trm
   type goal
   type inst
   val check : inst -> goal -> bool
   val check_term : inst -> trm -> bool
   val add_hyp : trm -> goal -> goal
   val num_hyps : goal -> int
   val interestingness : goal -> int
   val to_terms : goal -> term list * term
   val symbols : term -> string list
   (* term synthesis *)
   val gen_terms : goal -> term list
end

signature CONJ_GEN =
sig
  structure CGD : CONJ_GEN_DATA
  val filter_check : CGD.goal -> bool
  val generate : CGD.goal -> (CGD.trm list * CGD.trm list) -> CGD.trm list -> CGD.goal list  
end

(* should be possible to introduce search *)
functor ConjGen (CGD : CONJ_GEN_DATA)  = 
struct
  structure CGD = CGD;

   fun partition' f [] res = res
    |  partition' f (x::xs) (pos,neg) = 
          if f x then partition' xs (x::pos,neg)
                 else partition' xs (pos,x::neg);                                    
   fun partition f xs = partition' f xs ([],[]); 

  (* can we do better -> e.g. by knowing which variables c and all the counter-examples have *)
  (* (cP,nP) partitions P -> cP = captured P, nP = uncaptured P *)
  fun compute_changes N cP uP (newcond,newgoal) = 
   let (* Remove negative example which c handles  *)
     val N' = filter (CGD.check newgoal) N
     (* see how many new POS that has been captured (false means captured) *)
     val (new_captured,still_uncaptured) = partition (CGD.check_trm newcond) uP
     (* see how many captured that are now uncaptured (true means uncaptured) *)
     val (new_uncaptured,nP') = partition (CGD.check_goal newgoal) (nP @ new_captured)
     val cP' = still_uncaptured @ new_uncaptured;
     val new_neg = (length N) - (length N')
     val new_capt = length new_captured;
     val new_uncapt = lenght new_uncaptured;
   in
     ((new_neg,new_capt,new_uncapt),(N',cP',uP'))
   end;

  (* a naive heuristic - just the sum *)
  fun score (new_neg,new_capt,new_uncapt) = new_neg + new_uncapt - new_capt;     

  fun ord_tl [] = []
   |  ord_tl (x::xs) = (x,xs) :: ord_map xs

  datatype data = D of { 
    POS : CGD.inst list,
    NEG : CGD.inst list,
    cP : CGD.inst list,
    uP : CGD.inst list,
    N : CGD.inst list,
    goal : CDG.goal,
    C : trm list,
    score : int };

  (* really should be lazy  *)
  datatype STree = Leaf of int * data list
                 | Br of int * STree * STree

  datatype result = FAIL | SUCCESS of int | CONTINUE

  fun terminated data =
   case (#C data,#N data,#cP data) of 
      ([],[],cp) => SUCCESS (length cp) (* no more terms and no counter_examples *)
    | (_,[],[]) => SUCCES 0 (* no negeative and no capture postitive *)
    | ([],_,_) => FAIL (* no more terms (but still negative) *)
    | _ => CONTINUE; (* ALL OTHER CASES *)

  val filter_terminated = 
     fold (fn x => fn (s,c) => 
            case termianted x of FAIL => (s,c) | (SUCCESS n) => ((s,n)::s,c) | CONTINUE => (s,x::c))

  fun generate_one data (cond,conds) =
    let
      val newgoal = CGD.add_hyp cond (#goal data)
      val ((sn,psp,nsp),(n',cp',np')) = compute_changes (#N data) (#cP data) (#uP data) (cond,newgoal)
      (* note: score can be negative - ignore number of hyps!! *)
      val score' = score (sn,psp,nsp) 
    in
      (score',
       data |> set_goal newgoal
            |> set_N n'
            |> set_cP cp'
            |> set_nP np'
            |> set_C conds
            |> set_score (score' + (#score data))
    end;

  fun insert data [] = [data]
   |  insert data (x::xs) = if (#score data) < (#score x) 
                             then data::x::xs
                             else x::(insert data xs);

  fun insert_closed data [] = [data]
   |  insert_closed (n,data) ((nx,x)::xs) = 
         if n < x then (n,data)::(nc,x)::xs
                  else (nx,x)::(insert_closed (n,data) xs);

  fun generate_one data =
    (#C data)
    |> ord_tl
    |> map (generate_one data);

  fun generate_step ([],clsd) = ([],clsd)
   |  generate_step (data::xs,clsd) =
        let
          val datas' = generate_one data
          val (s,c) = filter_terminated datas'
          val opn = fold insert xs c
          val cls = fold insert_closed clds s
        in
           (opn,cls)
        end;

   fun generate n xs =
    let
      fun terminated ([],_) = true 
        | terminated _ = if n <= 0 then true else false
    in 
      if terminated xs then xs else generate (n-1) (generate_step xs)
    end;

  fun generate goal (POS,NEG) conds goal = 
    let
      val data = D {POS = POS, NEG = NEG, cP = [], uP = POS, N = NEG, goal = goal, C = cond, score = length NEG }
    in
      generate_step [data]
    end;

end


