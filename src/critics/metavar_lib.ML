(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *) 
(*  Title:      metavar_lib.ML
    Author:     Moa Johansson, University of Edinburgh
                moa.johansson@ed.ac.uk
*)

(* Some library functions for manipulating meta-variables              *)

(* TODO: 

- Instantiate meta-vars in cases where we want to use the
sub-term `below' the src_zipper

- Variant that keeps a new meta-variable around result of
instantiation eg. trying to find a lemma where more than one fucntion
symbol needs to go in the position of a meta-variable.  

*)

(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *) 

signature METAVAR_LIB =
sig

val inst_mvar : Var.name * Term.typ -> (* Name and type of meta-variable *)
                Zipper.T ->     (* Zipper of term with meta-variable. *)                
                Zipper.T ->      (* Zipper used to instantiate meta-variable *)  
                Prf.T ->          (* Current proof-plan *)
                Prf.T option      (* SOME pplan if successful instantiation found *)



val insert_metavars :  InstEnv.T ->         (* Current inst env from proof plan *)
                      (string * Term.typ) list -> (* Parameters, ie free vars in proof *)
                       Term.term ->                (* Term to insert meta-variables in *)  
                       DB_InstEnv.T * Term.term    (* Return instantiation env with new vars + 
                                                      term with metavariables *)

val insert_metavars_embedding :  InstEnv.T ->                (* Current inst env from proof plan *)
                             (string * Term.typ) list ->  (* Parameters, ie free vars in proof *)
                             Embed.T ->           (* ATerm to insert meta-variables in *)  
                             InstEnv.T * Term.term    (* Return instantiation env with new vars + term 
                                                            with metavariables *)

val n_args_right : Zipper.T -> int
                   
end

structure MetaVarLib (* : METAVAR_LIB *) = 
struct


(* -----------------------------------------------------------------*)
(* Instantiation of meta-variables                                  *)  
(* -----------------------------------------------------------------*)

(* Assuming z is at a meta-variable applied to some number of args,
how many more args exist higher up the zipper? *)
fun n_args_right z =
          case (Zipper.omove_up_right z) of 
            NONE => 0
          | SOME z' => 1 + n_args_right z';


(* Find an inatantiation for a meta-variable named n. `targ_zip' is a
zipper at a subterm with this meta-variable applied to some arguments
matching subterm in src_zip. `src_zip' is the zipper we use to
instantiate the variable, assumed to be located at a subterm that
matches one of the arguments to the meta-variable. The sub-term
`above' is what is used to instantiate the meta-variable. *)

fun inst_mvar (n,ty) targ_zip src_zip ppl =
    let                  
      val (argtyps,finaltyp) = Term.strip_type ty
      val i = n_args_right targ_zip 
      val src_typ = Term.type_of1 ((Zipper.ty_ctxt src_zip), (Zipper.trm src_zip))
      val ctxt = Prf.get_context ppl
      val herety = List.nth (argtyps, length argtyps - i - 1) 
      val ppl2opt = Prf.unify_typs [(herety,src_typ)] ppl
    in
     (case ppl2opt of NONE => NONE
                     | SOME ppl2 =>
                     let
                     val heretrm = Bound (i + length (Zipper.ty_ctxt src_zip))
                     val inst_t = Zipper.top_trm (Zipper.set_trm heretrm src_zip)
                     (* Might have found unifier for something in the src_typ so instantiate *) 
                     val top_src_typ = InstEnv.inst_typ_tvars (Prf.get_ienv ppl2) 
                                               (Term.type_of (Zipper.top_trm src_zip))
                     in 
                       (case (Prf.unify_typs [(finaltyp, top_src_typ)] ppl2)
                           of NONE => NONE
                            | SOME ppl3 =>
                              let
                                val var_inst = InstEnv.inst_trm 
                                                 (Prf.get_ienv ppl3)
                                                 (Term.list_abs (map (pair "") argtyps, inst_t))
                                val typ_inst = InstEnv.inst_typ_tvars (Prf.get_ienv ppl3) ty
                              in
                                SOME(Prf.inst_prf (InstEnv.add_var_inst (n, (typ_inst, var_inst)) 
                                                                        (InstEnv.init ctxt)) ppl3)
                                
                              end)
                       end)
     
    end; 



(* -----------------------------------------------------------------*)
(* Inserting meta-variables in terms                                *)
(* -----------------------------------------------------------------*)


(* Insert meta-variabls in a term. Meta-variables are inserted above
each function symbol *)
fun mk_metavar ienv params name typ = 
    let 
       val argtyps = map snd params
       val final_typ = argtyps--->typ 
       val (fresh_nm, ienv') = 
            InstEnv.new_uninst_var ((name, 0),final_typ) ienv
           
    in
        (ienv', Trm.mk_var (fresh_nm,final_typ))
    end;


fun ins_metavars ienv params Ts (Const(s,typ)) =   (ienv,(Const(s,typ)))
    | ins_metavars ienv params Ts (Free(s,typ)) =  (ienv,(Free(s,typ)))
    | ins_metavars ienv _ _ (Var(i,typ)) = (ienv, (Var(i,typ)))
    | ins_metavars ienv _ _ (Bound i) = (ienv,(Bound i))
    | ins_metavars ienv params Ts (Abs(s,typ,term)) = 
      let 
        val (ienv1, term1) = ins_metavars ienv params (typ::Ts) term 
      in
        (ienv1,(Abs(s,typ, term1)))
      end

    | ins_metavars ienv params Ts (t1$t2) =
      let                               
        val (f,args) = Term.strip_comb (t1$t2)
        val ty1 = Term.type_of1 (Ts, (t1$t2))
       
        val paramtrms = map (fn (name,typ) => (Free(name,typ))) params
        val argtyps = (ty1::(map snd params))(* @Ts *)
        val tp = argtyps--->ty1
        val (fresh_nm, ienv') = 
            InstEnv.new_uninst_var (("F", 0),tp) ienv

        (* Insert meta-variables in the arguments *)
        fun ins_in_args t (ienv,trms) = 
            let val (ienv', t') = ins_metavars ienv params Ts t in
              (ienv',t'::trms) end 
       
        val (ienv2,mts) = fold_rev ins_in_args args (ienv', [])

      in
        (* Insert the 'outermost' meta-variable *)
      (ienv2, Term.list_comb (Trm.mk_var (fresh_nm,tp),                               
                         ( (Term.list_comb (f, mts)) :: paramtrms) ))
      end;

(* Insert meta-vars. Just calls ins_metavars with accumulator for types set to [] *)
fun insert_metavars ienv goal_params t = 
      ins_metavars ienv goal_params [] t;

(* Insert meta-variables, but use aterms instead. Put a meta-variable
   in sink position, taking the contents of the sink as an
   argument. Note: this adds meta-vars around src term of the
   embedding. Else we'd need to take account of wave fronts *)
exception dbg_exp of ((string * Term.typ) list *
                     DB_Embed.T *
                     IsabelleTrmWrap.typ list *
                     DB_InstEnv.T * DB_ETerm.eterm)

fun ins_metavars_embedding params e Ts ienv (Ectxt.eConst (d,_)) = 
    (ienv, (Const d))
  | ins_metavars_embedding params e Ts ienv (Ectxt.eIntoBound ((en,i),_)) = 
    let val (wfn,c,et) = Embed.get_sub e en
        val Ts2 = TrmCtxt.ty_ctxt c
    in ins_metavars_embedding params e (Ts2@Ts) ienv et end
  | ins_metavars_embedding params e Ts ienv (Ectxt.eDestVar ((_,_,(d,_)),_)) = 
    (ienv, (Var d))
  | ins_metavars_embedding params e Ts ienv (Ectxt.eRelFree (((d1,d2),_),_)) = 
    (ienv, (Free d1))
  | ins_metavars_embedding params e Ts ienv (Ectxt.eBound ((d,_),_)) = 
    (ienv,(Bound d))
    (* For sinks, put meta-var with contents as an argument *)
  | ins_metavars_embedding params e Ts ienv (et as Ectxt.eSrcVar((ix,_,t),_)) = 
    let
        val ty1 = Ectxt.fastype_of_eterm_src (Embed.get_ectxt e) 
                                             (Ts,et);
 
        val paramtrms = map (fn (name,typ) => (Free(name,typ))) params
    in
      if (Term.is_Free t) then (* already in param list, so no need to add.*)
        let
          val argtyps = map snd params
          val tp = argtyps--->ty1  
          val (fresh_nm, ienv') = 
              InstEnv.new_uninst_var (("F", 0),tp) ienv         
          in
          (ienv', Term.list_comb(Trm.mk_var(fresh_nm, tp), paramtrms))
        end   
      else
        let
          val argtyps = (ty1::(map snd params))
          val tp = argtyps--->ty1
          val (fresh_nm, ienv') = 
              InstEnv.new_uninst_var (("F", 0),tp) ienv              
        in
          (ienv', Term.list_comb(Trm.mk_var(fresh_nm, tp), t::paramtrms))
        end      
    end


  | ins_metavars_embedding params e Ts ienv (Ectxt.eAbs((s,typ,et),_)) = 
    let val (ienv1, term1) = ins_metavars_embedding params e (typ::Ts) ienv et 
    in (ienv1,(Abs(s,typ, term1))) end

  | ins_metavars_embedding params e Ts ienv (et as Ectxt.eApp (et1, et2)) =
    let
      val (f,args) = Embed.Ectxt.dest_app et
      
      val ty1 = Ectxt.fastype_of_eterm_src (Embed.get_ectxt e) 
                                             (Ts,et);
                
      val paramtrms = map (fn (name,typ) => (Free(name,typ))) params
      val argtyps = (ty1::(map snd params))
      val tp = argtyps--->ty1
      val (fresh_nm, ienv') = 
          InstEnv.new_uninst_var (("F", 0),tp) ienv
          
      (* Insert meta-variables in the arguments *)
      fun ins_in_args et (ienv,trms) = 
          let val (ienv', t') = ins_metavars_embedding params e Ts ienv et in
            (ienv',t'::trms) end 
    
      val (ienv2, mts) = fold_rev ins_in_args args (ienv', [])
    in
      (* Insert the 'outermost' meta-variable *)
      (ienv2, Term.list_comb 
                (Trm.mk_var (fresh_nm,tp),
                 ((Term.list_comb (Embed.src (Embed.set_eterm f e), mts))
                  :: paramtrms) ))
    end

(* params = goal_params *)
fun insert_metavars_embedding params e = 
    ins_metavars_embedding 
      params e [] (Embed.get_ienv e) (Embed.get_eterm e);

end (* end struct *);
