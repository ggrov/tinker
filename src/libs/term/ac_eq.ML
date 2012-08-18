
(************************
 START HERE !!!

***********************)

signature COMMFUN =
sig

exception fun_not_commutative;
exception fun_not_associative;

structure CMTnames : SSTR_INT_NAME;
structure VAmorph : NAME_INJENDO;
structure CMTTab : NAME_TAB;

datatype comm_term =
     CommF  of term * comm_term list list  * comm_term list ;

(* *)
type comm_sig;
(* table from head function symbol (Const(f,ty)) to how the function is commutative *)
type comm_fun_table; 
(* head function symbols -> info about how its' associative (IMPROVE: currently 
   assumes assoc on all args, and table is id) *)
type ass_fun_table; 

val emptyCTab: comm_fun_table; 
val emptyATab: ass_fun_table;

(* raises exception if *)
val sign_of_comm_thm:  term -> comm_sig; 
(* raises exception if not assoc *)
val sign_of_ass_thm: term -> term ;

val add_comm_sign : comm_sig ->  comm_fun_table -> comm_fun_table;
val add_ass_sign : term  -> ass_fun_table -> ass_fun_table;
val add_comm_term: term -> comm_fun_table -> comm_fun_table;
val add_ass_term : term -> ass_fun_table -> ass_fun_table;
val add_comm_thm: Thm.thm -> comm_fun_table -> comm_fun_table;
val add_ass_thm : Thm.thm -> ass_fun_table -> ass_fun_table;

val isa_term_to_commtrm: comm_fun_table -> term -> comm_term;
val commterm_to_asstrm: ass_fun_table -> comm_term -> comm_term;
val eq_comm_trms: ass_fun_table -> comm_term -> comm_term -> bool;
val eq_isa_trms: ass_fun_table -> comm_fun_table -> term -> term-> bool;
val eq_isa_trms2:  ass_fun_table ->  comm_fun_table -> term -> term-> comm_term CMTTab.T list;
val match: ass_fun_table -> comm_term * comm_term -> comm_term CMTTab.T list -> comm_term CMTTab.T list;

val pretty: Proof.context -> comm_term -> Pretty.T;
val print: Proof.context -> comm_term -> unit;

end; 


structure Commfun : COMMFUN =
struct


datatype comm_term=
    CommF  of term * comm_term list list * comm_term list;

(* head function symbol, commutative argument permutations (int = original argument position), 
   other arguments (int = original argument position) *)
type comm_sig = term * int list list * int list; 

(* for: variable name to comm_term subsitutions *)
structure CMTnames :> SSTR_INT_NAME = SStrIntName;
structure VAmorph = NameInjEndoFun(CMTnames);
structure CMTTab = CMTnames.NTab;

structure CTab = Table(type key = term  val ord = Term_Ord.fast_term_ord );
structure ATab = Table(type key = term  val ord = Term_Ord.fast_term_ord );
val emptyCTab = CTab.empty; 
val emptyATab= ATab.empty;
type comm_fun_table = comm_sig CTab.table;
type ass_fun_table = term ATab.table;

val lookup = CTab.lookup;

exception fun_not_commutative;
exception fun_not_associative;

  
fun pretty ctxt (CommF (t,ll, l)) = 
    Pretty.block 
      [Trm.pretty ctxt t,
       Pretty.str "(",
       Pretty.list "{" "}" (map (fn l => Pretty.list "{" "}" (map (pretty ctxt) l)) ll),
       Pretty.list "[" "]" (map (pretty ctxt) l),
       Pretty.str ")"
       ]

val print = Pretty.writeln oo pretty; 

(* EXTRA FUNCTIONS *)

(*
(* make all possible pairs of elements of elements in a list*)
fun all_pairs [] _ = []
  | all_pairs (h::t) list = (map ((fn a => (fn b => (b,a)) h)) list)
                                    :: all_pairs t list;


fun make_combinations [] _ = []
   | make_combinations ((h as (h1,h2))::t) b= 
            
            (map (fn x => ((fn y => 
                  if List.exists (fn a => a = h1) (map fst x)  then [] 
                  else if  List.exists (fn a => a = h2) (map snd x) then []
                  else  y ::x) h  )) b) @
             make_combinations  t b; 

fun all_combinations list1 list2 = filter (fn a => length a = length list1)
                                  (fold make_combinations (
                                      all_pairs list1 list2 ) [[]]);
*)


(*all rotations 1 list gererates all the possible rotations of a list  *)

fun  generate_rotations list (h::t)  =
 if (t@[h]) = list then [] else (t@[h]) :: (generate_rotations list (t@[h]));


fun all_rotations 1 list =  list ::( all_rotations 2 list )
    |  all_rotations n list= 
       let
          val this_rotations = map (fn a => a@ (List.drop(list,n)))(generate_rotations (List.take(list,n))(List.take(list,n)));
       in 
       if n = length list then  this_rotations
       else this_rotations @  (List.concat( map (all_rotations (n+1))  (list::this_rotations)))
            
       end;



(*groups all non_Commutative terms of an associative function wrt a functio! 
TO CHANGE: it just do binary now *)
fun group_ass_terms f [] = []
  | group_ass_terms f [var] = []
  | group_ass_terms f (h1::t) = (CommF(f, [],[h1, hd t]) :: tl t) ::
                                      (map (fn a => (h1::a))(group_ass_terms f t)) ;

(*groups all Commutative terms of an associative function wrt a functio!
 TO CHANGE: it just do binary now *)

fun group_ass_terms2 f [] = []
  | group_ass_terms2 f [var] = []
  | group_ass_terms2 f (h1::t) = (CommF(f, [[h1, hd t]],[]) :: tl t) ::
                                   (map (fn a => ((hd t) ::a))(group_ass_terms2 f (h1:: (tl t)))) @
                                      (map (fn a => (h1::a))(group_ass_terms2 f t)) ;

(*drops element is position n from a list *)

fun drop_pos(list,0) = tl list
  |  drop_pos (list,n) = List.take(list,n) @ List.drop(list,n+1);


(* inserts a bijection in a list of bijectuions *)

fun insert_bij pos (var1,var2) [] = [(  (var1,var2) ,[pos, pos]  )]
   | insert_bij pos (var1,var2)  ( ((var11,var22), [pos1,pos2]) :: tl ) = 
        if(var2,var1) = (var11,var22) andalso pos1 = pos2
          then ((var11,var22), [pos1, pos]) :: tl
        else if var1 = var11 then raise fun_not_commutative
        else if var2 = var22 then raise fun_not_commutative
        else if var2 = var11  then raise fun_not_commutative
        else if var1 = var22 then raise fun_not_commutative
        else   ((var11,var22), [pos1, pos2]) :: (insert_bij pos (var1,var2) tl);

fun insert_bj pos1 pos2 ([],[])  = raise fun_not_commutative
    | insert_bj pos1 pos2 (v1::[], v2::[]) = raise fun_not_commutative
    | insert_bj pos1 pos2 (v11::v12::vars1, v21::v22::vars2)  = 
      if (*(Term.is_Free v11 andalso Term.is_Free v21) orelse*) (Term.is_Var v11 andalso Term.is_Var v21)
      then 
       (if v12 = v21 andalso v11=v22 then ((pos1,pos2), (vars1,vars2))
      else let 
        val ((a,b), (c,d))= insert_bj pos1 (pos2+1)  
        (v11::vars1, v21::vars2);
        in ((a,b),(v12::c,v22::d))
        end)
       else raise fun_not_commutative ;

(* inserta a list of bijections in a ist of permutations by mantaining disjoint cycles *)


fun update_permutations prm1 [] = [prm1]
   | update_permutations  prm1  ( prm2 :: perms )  = 
                            let
                            fun list_diff [] prm2 = []
                                | list_diff (p ::prm1) prm2 = 
                                  if List.exists (fn a=> a = p) prm2 then  list_diff  prm1 prm2
                                  else p ::  list_diff  prm1 prm2 
                            val perms_diff = list_diff prm1 prm2; 
                            in   
                              if perms_diff = [] then prm2 :: perms
                              else if perms_diff = prm1 
                                then prm2 :: update_permutations prm1 perms 
                              else   update_permutations  
                                        (perms_diff  @ prm2) perms 
                            end
                    


(*
Takes a commutative theorem and returns the signature for the function.  
Sigatures: function*commutative pos list list * not commutative pos list
*)

(* doesn't work for nested function commutative statements, e.g. len(a + b) = len(b + a)*)
(* NOte: doesn't store general permutations; only commutativity: i.e. arguments which can be 
   swapped. *)
(* FIXME: keep lists of args and check that the opposite of a permuation also works. 
   If not keep searching.
   FIXME: check that the arguments are free (or Var), i.e. not constants and not compounds terms, 
          and not abstractions. 
 *)
fun sign_of_comm_thm thm = let 
  val (Const("HOL.Trueprop", Type("fun", [Type("HOL.bool", []), Type("prop", [])]))) $
        (((Const("HOL.eq", Type("fun", [_, Type("fun", [_, Type("HOL.bool", [])])]))) $
          lhs) $ rhs) = thm; 
  val (f_lhs, var_lhs) = Term.strip_comb lhs;
  val (f_rhs, var_rhs) = Term.strip_comb rhs;
  (* count number of times a var appears on one side and ther other of an eq *)
  fun insert_var_in_list _ ([],[]) (comm_vars_list,noncomm_vars_list) =  
        (comm_vars_list,noncomm_vars_list)
    | insert_var_in_list _ ([],_) (comm_vars_list,noncomm_vars_list) = raise fun_not_commutative
    | insert_var_in_list _ (_,[]) (comm_vars_list,noncomm_vars_list) = raise fun_not_commutative
    | insert_var_in_list initial_pos (v1::vars1, v2::vars2) (comm_vars_list,noncomm_vars_list) = 
         if v1 =  v2 then 
            insert_var_in_list (initial_pos + 1) (vars1,vars2)
              (comm_vars_list, initial_pos :: noncomm_vars_list )
         else 
           let 
             val ((bj1,bj2),(r_vars1,r_vars2)) = 
                  insert_bj initial_pos (initial_pos+1) (v1::vars1,v2::vars2) ;
             val comm_vars_list'= [bj1,bj2]:: comm_vars_list;
           in insert_var_in_list  (initial_pos + 2) (r_vars1,r_vars2)
              (comm_vars_list', noncomm_vars_list) end
                
  val (comm_vars_list,noncomm_vars_list) =  insert_var_in_list 0 (var_lhs,var_rhs) ([],[]);
                                          
  (*val comm_vars_list' = map (fn ((a1,a2),b) => if (a1=a2) then raise fun_not_commutative
                            else b ) comm_vars_list*)

in 
    if (f_rhs=f_lhs) then 
      (f_lhs, comm_vars_list, noncomm_vars_list) 
    else raise fun_not_commutative                                           
    end;


      
(* takes an associative function annd a term and strips the term into its associative vars*)

fun strip_associative func var = if (Term.head_of var =func) 
                                      then snd(Term.strip_comb var) else [var];

fun sign_of_ass_thm thm = 
  let 
  val (Const("HOL.Trueprop", Type("fun", [Type("HOL.bool", []), Type("prop", [])]))) $
        (((Const("HOL.eq", Type("fun", [_, Type("fun", [_, Type("HOL.bool", [])])]))) $
          lhs) $ rhs) = thm;
  val (f_lhs, var_lhs) = Term.strip_comb lhs;
  val (f_rhs, var_rhs) = Term.strip_comb rhs;
  val strip_lhs = List.concat (map (strip_associative f_lhs) var_lhs);
  val strip_rhs = List.concat (map (strip_associative f_rhs) var_rhs);
in  
  if f_lhs = f_rhs andalso (strip_lhs = strip_rhs)
     andalso (* ((filter (Term.is_Free) strip_lhs = strip_lhs) 
              andalso (filter (Term.is_Free) strip_rhs = strip_rhs))
     orelse *)((filter (Term.is_Var) strip_lhs = strip_lhs) 
              andalso (filter (Term.is_Var) strip_rhs = strip_rhs)) 
    then  f_lhs 
  else raise fun_not_associative
end;



(*
fun sign_of_comm_thm thm = let 
  val (Const("HOL.Trueprop", Type("fun", [Type("HOL.bool", []), Type("prop", [])]))) $
          eq $ lhs $ rhs = thm; 
  val (f_lhs, var_lhs) = Term.strip_comb lhs;
  val (f_rhs, var_rhs) = Term.strip_comb rhs;
  fun insert_var_in_list _ ([],[]) comm_vars_list =   comm_vars_list
    | insert_var_in_list _ ([],_) comm_vars_list = raise fun_not_commutative
    | insert_var_in_list _ (_,[]) comm_vars_list = raise fun_not_commutative
    | insert_var_in_list initial_pos (v1::vars1, v2::vars2) comm_vars_list = 
         if v1 =  v2 then 
            insert_var_in_list (initial_pos + 1) (vars1,vars2) comm_vars_list
         else 
           let 
             val comm_vars_list' = insert_bij initial_pos (v1,v2) comm_vars_list;
           in insert_var_in_list  (initial_pos + 1) (vars1,vars2) comm_vars_list' end
                
  val comm_vars_list =  insert_var_in_list 0 (var_lhs,var_rhs) [];
                                          
  val comm_vars_list' = map (fn ((a1,a2),b) => if (a1=a2) then raise fun_not_commutative
                            else b)  comm_vars_list

in 
    if (f_rhs=f_lhs) then 
      (f_lhs, comm_vars_list') 
    else raise fun_not_commutative
    end;
*)

(* takes a table and a commutative function signature and adds it to the table*)



fun  add_comm_sign (func,comm_vars,noncomm_vars)  table = 
case CTab.lookup table func of NONE => 
        CTab.update_new (func,(func,comm_vars,noncomm_vars))  table
       | SOME (func',comm_vars',noncomm_vars') =>  let  
        val new_comm_vars =  fold update_permutations comm_vars comm_vars';
        fun make_noncomm_vals 0= []
        | make_noncomm_vals n = if List.exists (fn a => a = (n-1) )(List.concat new_comm_vars) then make_noncomm_vals (n-1)
                          else (n-1):: (make_noncomm_vals (n-1));
        val new_noncomm_vals = make_noncomm_vals  (List.length ( fst  (Term.strip_type  ( Term.type_of func))) );
        in CTab.update (func,(func,new_comm_vars,new_noncomm_vals)) table end
   


fun add_ass_sign func table = 
    case ATab.lookup table func of NONE =>  ATab.update_new (func,func)  table
 | SOME a => table; 

(* takes an equation stating a commutative or associative theorem and adds
 the corrispective function to a table*)

fun add_comm_term t table = 
  add_comm_sign ( sign_of_comm_thm t) table;
 
fun add_ass_term t table = 
  add_ass_sign ( sign_of_ass_thm t) table; 

fun add_comm_thm thm com_tab = 
    add_comm_term (Thm.concl_of thm) com_tab;

fun add_ass_thm thm asc_tab =
    add_ass_term (Thm.concl_of thm) asc_tab;
 
(* takes a term and a commutative functions table and it returns the comm_fun of the term.  *)

(* IMPROVE: handle lambda abstractions in head of term: basically just need to decend through them 
   and do the same. *)
fun isa_term_to_commtrm table term = let
  val  (f, vars) = Term.strip_comb term;

in 
  if vars = [] then CommF (term, [],[])
  else
    case CTab.lookup table f of 
          NONE  => CommF (f, [[]], map (isa_term_to_commtrm table) vars) 
          | SOME (f,comm_vars,noncomm_vars) => let 
                                       val comm_vars' = map ( map (fn a =>  (List.nth(vars,a)))) comm_vars;
                                       val noncomm_vars' = map (fn a =>  (List.nth(vars,a))) noncomm_vars;
                                       in CommF (f, 
                                         map (map (isa_term_to_commtrm table)) comm_vars',
                                         map (isa_term_to_commtrm table) noncomm_vars') end
end;


(* IMPROVE: change into three simple recursive functions, one for AC, one for A, one for C *)
(*takes an associative function annd a commutative term and strips the term into its associative vars*)
fun strip_ass_comm func (CommF(term, [], [])) = 
       [(CommF(term, [], []))]
  | strip_ass_comm func (CommF(term, comm_terms, noncomm_terms)) = 
         if term = func andalso 
                  (length noncomm_terms = 2  andalso length comm_terms = 0) 
        then List.concat ( map (strip_ass_comm func) noncomm_terms)
          
        else if term = func andalso 
                  (length noncomm_terms = 0  andalso map length comm_terms = [2] )
        then  List.concat (  map (strip_ass_comm func) (hd comm_terms))
          
       else  [(CommF(term, comm_terms, noncomm_terms))];


(* flattern a comm_term w.r.t. associativity *)
fun commterm_to_asstrm table (CommF(term, [], [])) = (CommF(term, [], []))
  | commterm_to_asstrm table (cmterms as (CommF(term, comm_terms, noncomm_terms)) )= 
      case ATab.lookup table term of 
          NONE => (CommF (term, 
                          map (map (commterm_to_asstrm table)) comm_terms, 
                          map (commterm_to_asstrm table) noncomm_terms) )
          | SOME (afun) => 
                  (* only associative *)
                  if (length noncomm_terms = 2  andalso length comm_terms = 0) 
                  then (CommF (term, 
                          map (map (commterm_to_asstrm table)) comm_terms, 
                          map (commterm_to_asstrm table)
                              (strip_ass_comm afun cmterms) ))
                  (* AC *)
                  else if (length noncomm_terms = 0  andalso map length comm_terms = [2] )
                  then (CommF (term, 
                          map (map (commterm_to_asstrm table)) 
                          (* single is special case from [2] *) 
                          [strip_ass_comm  afun cmterms], 
                          (* for special case this is [] *)
                          map (commterm_to_asstrm table) noncomm_terms 
                          ))
                  (* only C *)
                  else (CommF (term, 
                          map (map (commterm_to_asstrm table)) comm_terms, 
                          map (commterm_to_asstrm table) noncomm_terms) ); 





(*
fun add_match (v1,v2)   [] = []
  | add_match (v1,v2) (env::envl) = 
       case env |> VAmorph.try_change1 v1 v2 
         of NONE =>  add_match (v1,v2) envl 
            | SOME am' =>  (am'  :: (add_match (v1,v2) envl ));

*)


(* add a match between a variable (of comm_term type ) and a comm_term to the matching table *)
fun add_match (v1,v2)   [] = []
  | add_match (v1,v2) (env::envl) = 
      case v1 |>  CMTTab.lookup env  of 
        SOME v =>  if (v2=v) then   env :: (add_match (v1,v2) envl ) else (add_match (v1,v2) envl )
       | NONE => (CMTTab.ins (v1,v2) env) :: (add_match (v1,v2) envl );



(* takes table of associative functions, a pair off comm_terms and a list of matching tables and
 returns a list of matching tables. Returns empty if they don't match *) 
exception aaaaaa;
(* if trying to match a comm_term variable and comm_term and they cooncorde in type,
 try to add the match to each matching table so far*)
fun  match atable (v1 as (CommF( Var(var1, typ1), [], [])), v2 as(CommF(fct, comm_vars, noncomm_vars))) 
            env =
            if (typ1 = (snd o Term.strip_type o Term.type_of) (fct) )  then     
            add_match (CMTnames.mk var1, commterm_to_asstrm atable v2  ) env            
     else env
  (*|match atable (v1 as (CommF( Free(var1, typ1), [], [])), v2 as(CommF(fct, comm_vars, noncomm_vars))) 
            env =
            if (typ1 = (snd o Term.strip_type o Term.type_of) (fct) )  then     
            add_match (CMTnames.mk var1, commterm_to_asstrm atable v2  ) env 
     else env*)
   (*trying to match a non-var comm_term and a var comm_terms fails *)
   (*| match atable (_ , (CommF( Free(var1, typ1), [], [])))  env = []*)
   | match atable (_ , (CommF( Var(var1, typ1), [], [])))  env = []
   (*general case *)
   | match atable (v1 as CommF( f1, comm_vars1, noncomm_vars1), 
            v2 as CommF (f2, comm_vars2, noncomm_vars2))
             env = 
            if (f1 = f2) 
            then  match_comml (f1,atable) (comm_vars1, comm_vars2) 
                  ( match_non_comml  (f1,atable) (noncomm_vars1, noncomm_vars2)   env)
            else []      

and match_all_noncomm_comb (f,atable) (_,[]) env = []
    | match_all_noncomm_comb (f,atable) (vars1,(v::vars2)) env = 
      (match_non_comml   (f,atable) (vars1, v) env ) @ (match_all_noncomm_comb (f,atable) (vars1,vars2) env)        
(* tryes to match two list of non commutative comm_terms*)
and match_non_comml (f,atable) (comm_vars1, comm_vars2)   env = 
     (* if they are the same length try matching*)
    if length comm_vars1 = length comm_vars2 then  fold (match atable) (comm_vars1 ~~ comm_vars2) env
       (*if they are not the same length, try all the possible associative 
   combinations of the the second list and try match against each of these *)
    else if ATab.defined atable f andalso length comm_vars1 < length comm_vars2
      then let
          val comm_vars_2_grouping = group_ass_terms f  comm_vars2;
          val all_comb = map (fn a => (comm_vars1  ~~ a)) comm_vars_2_grouping;
      in  match_all_noncomm_comb (f,atable) (comm_vars1,comm_vars_2_grouping) env end
    else []
and match_all_pairs (f,atable) [] env = []
   | match_all_pairs (f,atable) (h::t) env =
        let 
          val env' =fold (match atable)  h  env;
           val rec_env =   match_all_pairs (f,atable) t  env;
         in  env' @ rec_env
         end

and match_all_comm_comb (f,atable) (_,[]) env = []
    | match_all_comm_comb (f,atable) (vars1,(v::vars2)) env = 
      (match_comm   (f,atable) (vars1, v) env ) @ (match_all_comm_comb (f,atable) (vars1,vars2) env)

(* matches one list of comm_term agains another list of comm_term *)
and match_comm   (f,atable) ([],[])   env = env
  | match_comm   (f,atable)   (comm_vars1, comm_vars2)  env   = 
    (* if they are the same length try matching*)
    if length comm_vars1 = length comm_vars2  then 
      match_all_pairs (f,atable)  (map (fn a => ((fn b => b~~a)(comm_vars1))) 
                                          (all_rotations 1 comm_vars2)) 
                                         env
   (*if they are not the same length, try all the possible associative 
   combinations of the the second list and try match against each of these *)
    else if ATab.defined atable f andalso length comm_vars1 < length comm_vars2 
     then let
          val comm_vars_2_grouping = group_ass_terms2 f  comm_vars2;
          in match_all_comm_comb   (f,atable) (comm_vars1,  comm_vars_2_grouping ) env end
    else []

(* tryes to match a list of comm_terms against all the possible lists of comm_terms*)
and match_one_list (f,atable) l1 []   env = []
   | match_one_list _ l1 _  []  = []
   | match_one_list (f,atable)  l1 (l2::vars)  env = 
      let 
        val env' = match_comm (f,atable) (l1,l2)  env;
        val rec_env =
             (match_one_list (f,atable) l1 vars  env);
       in env' @ rec_env end
(* tryes to match a list of list of commutative terms*)
and match_comml  (f,atable)   ([],_) env =  env
  |match_comml (f,atable) ((l1::comm_vars1), (comm_vars2))  env  = 
      match_one_list (f,atable) l1 comm_vars2  (match_comml (f,atable) (comm_vars1,comm_vars2)  env);




(*

fun  list_sort_fst n list =  List.nth(list,n) :: (List.take(list,n) @ List.drop(list,n+1)) ;


fun match ((CommF( Free(var1, typ1), [], [])),(CommF (Free(var2, typ2), [], []))) env  = 
     if (typ1 = typ2)  then add_match (var1,var2) env
    else raise match_failed
  |match ( CommF( f1, comm_vars1, noncomm_vars1) , CommF (f2, comm_vars2, noncomm_vars2))env = 
   if (f1 = f2) then  match_comml 0 (comm_vars1, comm_vars2) 
                                    ( match_non_comml  (noncomm_vars1, noncomm_vars2) env)
             else raise match_failed           

and match_non_comml (l1, l2) env = 
    if length l1 = length l2 then  fold match  (l1 ~~ l2) env
    else raise match_failed

and match_comm  index ([],[]) env = env
  |match_comm  index ((l1::comm_vars1), (l2::comm_vars2)) env  = 
    if length comm_vars1= length comm_vars2 then 
      match  (l1,l2) (match_comm  0 (comm_vars1,comm_vars2) env)
        handle match_failed =>
          (if (index = length comm_vars1) then raise match_failed
          else
          match_comm (index+1) ((l1::comm_vars1),(list_sort_fst (index+1) (l2::comm_vars2)) ) env   
          )
    else raise match_failed

and match_comml  index ([],[]) env = env
  |match_comml  index ((l1::comm_vars1), (l2::comm_vars2)) env  = 
    if length comm_vars1= length comm_vars2 then 
     match_comm  0  (l1,l2) (match_comml 0  (comm_vars1,comm_vars2) env)
        handle match_failed =>
          (if (index = length comm_vars1) then raise match_failed
          else
          match_comml (index+1) ((l1::comm_vars1),(list_sort_fst (index+1) (l2::comm_vars2)) ) env   
          )
    else raise match_failed;
*)


fun eq_comm_trms atable term1 term2 = 
  let 
    val env = match atable (term1,term2) [CMTTab.empty];
  in List.exists  (not o CMTTab.is_element_empty )  env end;

fun eq_isa_trms  atable ctable term1 term2 = let
    val comm_term1 = isa_term_to_commtrm ctable term1;
    val comm_term2 = isa_term_to_commtrm ctable term2;
    val ass_term1 = commterm_to_asstrm atable comm_term1;
    val ass_term2 = commterm_to_asstrm atable comm_term2;
    in 
    eq_comm_trms  atable ass_term1 ass_term2
    end;

fun eq_isa_trms2 atable ctable term1 term2  = let
    val comm_term1 = isa_term_to_commtrm ctable term1;
    val comm_term2 = isa_term_to_commtrm ctable term2;
    val ass_term1 = commterm_to_asstrm atable comm_term1;
    val ass_term2 = commterm_to_asstrm atable comm_term2;
    in match atable
   (ass_term1,ass_term2)   [CMTTab.empty]
    end;


end; 


