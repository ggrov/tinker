(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *) 
(*  Title:      ./base/pscript.ML
    Author:     Lucas Dixon, University of Edinburgh
                lucas.dixon@ed.ac.uk
*)
(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *) 
(*  DESCRIPTION:

    The basic script language elements: 
    generic and extensible proof script language. 

*)
signature PSCRIPT = 
sig

  type stepT
  type T

  exception pscript_exp of (string * T)

    val add_step_i : stepT -> T -> T
    val addstepf : (stepT -> stepT) -> T -> T
    val init_pscript : string -> stepT -> T
    val name_of : T -> string

    val kind_of_step : stepT -> SafeObject.kind 
    val pst_of_step : stepT -> Proof.state
    val name_of_step_kind : stepT -> string
    val goalterms_of_step : stepT -> Term.term list;
    val mk_getdataf :
       SafeObject.kind -> (SafeObject.T -> 'a) -> stepT -> 'a option

    val mk_init_step :
       ('a -> Proof.state * Term.term list) 
       * ('a -> Pretty.T) 
       * ('a -> SafeObject.kind * SafeObject.T) 
       -> 'a -> stepT
    val mk_stepf :
       (* applyf *)
       ('a -> (Proof.state * Term.term list) -> (Proof.state * Term.term list))
       (* prettyf *) 
       * ('a -> Proof.context -> (int * Pretty.T)) 
       (* encoding function  *)
       * ('a -> SafeObject.kind * SafeObject.T) 
       -> 'a (* data *)
       -> stepT (* from instance of old step *)
       -> stepT (* to instance of new step *)

    val drop_last_step : T -> T
    val drop_all_steps : T -> T

    val steps_of : T -> stepT * stepT list
    val stepsl_of : T -> stepT list

    val top_step_of : T -> stepT
    val top_pst_of : T -> Proof.state
    val top_ctxt_of : T -> Proof.context
    val top_thm_of : T -> Thm.thm
    val top_goalterms_of : T -> Term.term list

    val pretty : T -> Pretty.T
    val pretty_top_pst : T -> Pretty.T list
    val pretty_step : stepT -> int * Pretty.T

    (* result name management *)
    val new_rname : (string * T) -> (IntNames.name * T)
    val another_rname : (IntNames.name * T) -> (IntNames.name * T)

    (* a function to hack with the proof state *)
    val apply_pstf : ((Proof.state * Term.term list) 
                      -> (Proof.state * Term.term list)) -> T -> T

end;



(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *) 
structure PScript : PSCRIPT = 
struct

(* note that many proof steps are whole proofs! *) (* note in future
we may augment this to also include theory formation such as constant
definitions etc. *)
datatype stepT = 
     pstep of {
      kind : SafeObject.kind,
      data : SafeObject.T,  (* may contain more proofs! *)
      pretty : unit -> int * Pretty.T,
      pst : Proof.state,
      goals : Term.term list  (* the goals to be shown, what the goal 
                                 *should* look like, ie with fixed vars etc
                                 This is a hack as Isar should really be 
                                 doing this. *)
     };

datatype T = pscript of { 
         name : string,
         steps : stepT * stepT list,
         rnames : IntNames.tab }; 
(* Isar should be managing local result names also. *)


exception pscript_exp of (string * T);

val goals_of_pst = map Logic.strip_imp_concl o Thm.prems_of 
                   o snd o snd o Proof.get_goal;

fun pst_of_step (pstep rep) = #pst rep;
fun goalterms_of_step (pstep rep) = #goals rep;
fun kind_of_step (pstep rep) = (#kind rep);
fun name_of_step_kind (pstep rep) = SafeObject.name_of_kind (#kind rep);

fun name_of (pscript rep) = (#name rep);
fun steps_of (pscript rep) = (#steps rep);
fun stepsl_of (pscript rep) = (op ::) (#steps rep);
fun rnames_of (pscript rep) = (#rnames rep);
val top_step_of = fst o steps_of;
val top_pst_of = pst_of_step o top_step_of;
val top_ctxt_of = Proof.context_of o top_pst_of;
val top_thm_of = snd o snd o Proof.get_goal o top_pst_of;
val top_goalterms_of = goalterms_of_step o top_step_of;

fun add_step_i newstep (pscript {steps = (last, more), rnames, name}) = 
    (pscript {steps = (newstep, last::more), rnames = rnames, name = name});
fun addstepf stepf pp = 
    add_step_i (stepf (top_step_of pp)) pp;

fun drop_last_step pp = 
    case steps_of pp of (_,[]) => pp
      | (_, (h::t)) => pscript {steps = (h,t), 
                                rnames = rnames_of pp, 
                                name = name_of pp};

fun drop_all_steps pp = 
    case steps_of pp of (_,[]) => pp
      | _ => drop_all_steps (drop_last_step pp);

fun pretty_step (pstep rep) = 
    (* Pretty.indent (Proof.level (#pst rep)) *)
      (#pretty rep)();

(* managing result names *)
fun set_rnames rnames (pscript rep) = 
    pscript {steps = #steps rep,
             rnames = rnames,
             name = #name rep};

fun new_rname (s,pp) = 
    let val (n,rnames) = IntNames.new (s, rnames_of pp) in
      (n, set_rnames rnames pp)
    end;

fun another_rname (n,pp) = 
    let val (n2,rnames) = IntNames.another (n, rnames_of pp) in
      (n2, set_rnames rnames pp)
    end;


(* creating proof scripts *)
fun init_pscript name initstep = 
    pscript {steps = (initstep, []), rnames = IntNames.empty, name = name};

fun mk_init_step (startf, prettyf, enc) (d : 'a) = 
    let 
      val (kind, generic_d) = enc d
      val (pst, goals) = startf d
    in
      pstep {kind = kind, 
             data = generic_d, 
             pretty = (fn () => (0, prettyf d)), 
             pst = pst,
             goals = goals}
    end;

(* to edit the latest pst directly - this should not be used except
for initialisation purposes as it is a 'hidden' step. It does allus us
to do some nice tricks with Isar scripts, like pretend we are another
script by faking its context, this then allows results to be used in
the original script. *)
fun apply_pstf f (pscript {steps = (pstep { kind, data, pretty, pst, goals }, 
                                    t), 
                           rnames,
                           name}) = 
    let val (pst', goals') = f (pst, goals) in
      pscript {steps = 
               (pstep { kind = kind, data = data, 
                        pretty = pretty, pst = pst', 
                        goals = goals' }, t),
               rnames = rnames,
               name = name}
    end;

(* create a proof step function *)
fun mk_stepf (applyf, prettyf, enc) (d : 'a) oldstep = 
    let 
      val pst = pst_of_step oldstep
      val goals = goalterms_of_step oldstep
      val (kind, generic_d) = enc d
      val (pst',goals') = applyf d (pst, goals)
    in
      pstep {kind = kind, 
             data = generic_d, 
             pretty = (fn () => prettyf d (Proof.context_of pst)), 
             pst = pst',
             goals = goals' }
    end;

(* create a function to get the data from a proof step *)
fun mk_getdataf kind decf (pstep {kind = k, data = d, ... }) = 
    if SafeObject.eq_kind (k, kind) then SOME (decf d) 
    else NONE;

fun pretty (pscript {steps = (laststep, moresteps), rnames, name}) = 
    let 
      fun pf i [] = []
        | pf i (s::ss) = let val (i2,p) = pretty_step s in
                           (Pretty.indent (i * 2) p) :: (pf (i + i2) ss)
                         end
    in
      Pretty.chunks (pf 0 (rev (laststep::moresteps)))
    end;

(* implicit proofplan *)
val pretty_top_pst = (Proof.pretty_goals false) o (* false for local goals, not main ones - not sure what effect this actually has: maybe one is with params? one without? *) 
                      top_pst_of;

end;


(* signature for kinds of elements of a proof plan, to be used in a
functor to get back a sturcture for elements of a proof plan *)
signature PSCRIPT_ELEM_KIND = 
sig
      type T
      val name : string
      val applyf : T -> Proof.state * Term.term list 
                   -> Proof.state * Term.term list
      val prettyf : T -> Proof.context -> (int * Pretty.T)
      val copy : T -> T (* Identity if refs in T, else need to copy refs *)
end;


(* signature of a proof script element *)
signature PSCRIPT_ELEM = 
sig

  val kind : SafeObject.kind

  type T

  val stepf : T -> PScript.stepT -> PScript.stepT
  val data_of : PScript.stepT -> T option

  val addstep : T -> PScript.T -> PScript.T

end;




(* functor to make a PSCRIPT_ELEM from a PSCRIPT_ELEM_KIND, i.e. to do
the dull work that all Proof Script elements will need: this is
basically lifting to a polimorphic type, outwitting the type system
using exceptions.  *)
functor PScriptElemFUN (structure K : PSCRIPT_ELEM_KIND)
        : PSCRIPT_ELEM = 
struct

val kind = SafeObject.kind K.name;

type T = K.T;
exception Data of T;

fun data_of_obj (Data x) = x;

fun encf d = (kind, Data d);

(* implicit extra args: data : K.T,  pst : Proof.state,  
   then returns a new proof state *)
val stepf = PScript.mk_stepf (K.applyf, K.prettyf, encf);

(* implicit extra args: PScript.stepT, then returns a K.T option *)
val data_of = PScript.mk_getdataf kind data_of_obj;

(* implicit arg: T, PScript.T, then returns PScript.T*)
val addstep = PScript.addstepf o stepf;

end;





(* For Creating new proof plans, ie starting them! *)

(* signature for kinds of elements of a proof plan, to be used in a
functor to get back a sturcture for elements of a proof plan *)
signature PSCRIPT_CONSTR_KIND = 
sig
      type T
      val name : string
      val startf : T -> Proof.state * Term.term list
      val prettyf : T -> Pretty.T
      val copy : T -> T (* Identity if refs in T, else need to copy refs *)
end;

(* signature of a proof script element *)
signature PSCRIPT_CONSTR = 
sig

  val kind : SafeObject.kind

  type T

  val stepf : T -> PScript.stepT
  val data_of : PScript.stepT -> T option
  val mkplan : string -> T -> PScript.T

end;



(* functor to make a PSCRIPT_ELEM from a PSCRIPT_ELEM_KIND, i.e. to do
the dull work that all Proof Script elements will need: this is
basically lifting to a polimorphic type, outwitting the type system
using exceptions.  *)
functor PScriptConstrFUN (structure K : PSCRIPT_CONSTR_KIND)
        : PSCRIPT_CONSTR = 
struct

val kind = SafeObject.kind K.name;

type T = K.T;
exception Data of T;

fun data_of_obj (Data x) = x;

fun encf d = (kind, Data d);

(* implicit extra args: data : K.T,
   then returns a new PScript.stepT *)
val stepf = PScript.mk_init_step (K.startf, K.prettyf, encf);

(* implicit extra args: PScript.stepT, then returns a K.T option *)
val data_of = PScript.mk_getdataf kind data_of_obj;

(* implicit arg: K.T, then returns PScript.T*)
fun mkplan name d = PScript.init_pscript name (stepf d);


end;



