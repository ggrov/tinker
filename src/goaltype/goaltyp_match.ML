signature GOALTYP_MATCH_SHARING =
sig
  structure GoalTyp: GOAL_TYP_SHARING
  structure Link : LINK_SHARING
  structure Class : CLASS_SHARING
  structure GoalTypData : GOALTYP_DATA_SHARING
  structure Prover : PROVER_SHARING
  structure MatchParam : MATCH_PARAM_SHARING
 (* structure Atomic : ATOMIC_SHARING  maybe not *)
end

signature GOALTYP_MATCH =
sig
  structure GoalTyp : GOAL_TYP 
  structure Link : LINK
  structure Class : CLASS
  structure GoalTypData : GOALTYP_DATA
  structure Prover : PROVER
  structure Atomic : ATOMIC
  structure MatchParam : MATCH_PARAM
  sharing GoalTypData.Sharing = Link.Sharing.GoalTypData
  sharing GoalTypData.Sharing = Class.Sharing.GoalTypData
  sharing GoalTypData.Sharing = MatchParam.Sharing.GoalTypData
  sharing Link.Sharing = GoalTyp.Sharing.Link
  sharing Class.Sharing = GoalTyp.Sharing.Class
  sharing Prover.Sharing = GoalTypData.Sharing.Prover
  sharing Prover.Sharing = MatchParam.Sharing.Prover
  sharing type Atomic.Sharing.context = Prover.Sharing.context
  sharing type Atomic.Sharing.fact = Prover.Sharing.thm (* FIXME sounds bad, very hacky*)

  exception class_match_exp of string * C.name
  exception link_match_exp of string * L.name
                     
  val class_match : Class.T-> Prover.context -> Prover.term -> bool

  val link_data_ll_match : F.name -> Prover.context 
                              -> Prover.term list -> Prover.term list
                              -> GoalTypData.data list list -> bool
(*  val link_data_ll_match' : F.name -> Prover.context 
                               -> Prover.term list -> Prover.term list
                               -> GoalTypData.data list -> (Prover.term * Prover.term) list option*)

  val match : GoalTyp.T -> GNode.T -> Atomic.pnode -> bool
  val lift : GoalTyp.T -> GNode.T -> Atomic.pnode -> GNode.T option
 
  structure Sharing : GOALTYP_MATCH_SHARING
    sharing Sharing.GoalTyp = GoalTyp.Sharing
    sharing Sharing.Link = Link.Sharing
    sharing Sharing.Class = Class.Sharing
    sharing Sharing.GoalTypData = GoalTypData.Sharing
    sharing Sharing.Prover = Prover.Sharing
    sharing Sharing.MatchParam = MatchParam.Sharing
    (*sharing Sharing.Atomic = Atomic.Sharing*)

end (* signature *)

functor GTMatchFun (structure GoalTyp : GOAL_TYP 
                    structure Link : LINK
                    structure Class : CLASS
                    structure GoalTypData : GOALTYP_DATA
                    structure Prover : PROVER
                    structure Atomic : ATOMIC
                    structure MatchParam : MATCH_PARAM
                    sharing GoalTypData.Sharing = Link.Sharing.GoalTypData
                    sharing GoalTypData.Sharing = Class.Sharing.GoalTypData
                    sharing GoalTypData.Sharing = MatchParam.Sharing.GoalTypData
                    sharing Link.Sharing = GoalTyp.Sharing.Link
                    sharing Class.Sharing = GoalTyp.Sharing.Class
                    sharing Prover.Sharing = GoalTypData.Sharing.Prover
                    sharing Prover.Sharing = MatchParam.Sharing.Prover
                    sharing type Atomic.Sharing.context = Prover.Sharing.context
                    sharing type Atomic.Sharing.fact = Prover.Sharing.thm
                    ) : GOALTYP_MATCH =
struct

  structure GoalTyp = GoalTyp;
  structure Link = Link;
  structure Class = Class;
  structure GoalTypData = GoalTypData;
  structure Atomic = Atomic;
  structure Prover = Prover;  
  structure MatchParam = MatchParam;


  exception class_match_exp of string * C.name
  exception link_match_exp of string * L.name


  val class_data_match = MatchParam.class_data_match
  val link_data_match = MatchParam.link_data_match

  fun class_match class ctxt trm = 
    let 
      fun matches (data :: datal) fname =  
            if class_data_match fname ctxt trm data 
            then true 
            else matches datal fname
        | matches [] fname = false;
      fun strip_some (SOME x) = x
    in
      map (fn fname => matches (Class.get_item fname class |> strip_some) fname) (Class.get_keys class)
      |> filter (fn x => x = false)
      |> (fn x => (case x of [] => true | _ => false))
    end
(*
  val link_match : Link.T -> Prover.context -> (Prover.term * Prover.term) -> bool
  val link_match' : Link.T -> Prover.context -> Prover.term list -> Prover.term list -> (Prover.term * Prover.term) list
*)
 
 fun link_data_ll_match' fname (ctxt : Prover.context) (tl1 : Prover.term list) (tl2 : Prover.term list) datal =
   let
      fun link_match0 name (t1, t2) =
        let 
          fun matches (data :: dl) =  
                if link_data_match name ctxt (t1,t2) data 
                then true 
                else matches dl
            | matches [] = false;
          fun strip_some (SOME x) = x
        in
          matches datal
        end
      fun merge_pair (x, (y :: ys)) l = merge_pair (x, ys) [(x, y)] @ l
        | merge_pair (x, []) l = l
  in
      map
        (fn x => 
          (filter (fn y => link_match0 fname (x,y)) tl2 (* filter the matched terms for x in tl2 *)
          |> (fn p => (x,p)))) (* pair them *)
        tl1
      (* get a list of pair which matches, e.g.[(a,l1)] where a is the term, l1 conatins terms which matches a1
         now we need to filter thoes pairs where l1 is empty. 
         Also we need to change the type from (term * term list) list to (term * term) list *)
      |> filter (fn (x,y) => (case y of [] => false | _ => true))
      |> (fn l => fold merge_pair l [])
      |> (fn x => case x of [] => NONE | _ => SOME x)
    end

  fun link_data_ll_match fname ctxt tl1 tl2 dl= case link_data_ll_match' fname ctxt tl1 tl2 dl of NONE => false | _ => true

 
 (* 
  val match : GoalTyp.T -> GNode.T -> Atomic.pnode -> bool
  val lift : GoalTyp.T -> GNode.T -> Atomic.pnode -> GNode.T option
 *)
  fun lift gtyp gnode pnode =       
    let
      val gterm = Atomic.get_pnode_goal pnode (* fact of pnode goal *) (* FIXME: what happen if in the middle of proof *)
                  |> Prover.concl_of_thm; (* goal term *)
      val ctxt = Atomic.get_pnode_ctxt pnode
    in
      if class_match (GoalTyp.get_gclass gtyp) ctxt gterm (* check if the goal class fits*) 
        then 
          (let 
             val cname_factList = (* a list of pair (cname, facts list), *)
               map (fn cls => (
                                (filter (fn y => snd y |> class_match cls ctxt) 
                                (* facts list : (name * trm) list*)
                                (map (fn x => (fst x, Prover.trm_of_thm (snd x))) 
                                  (Atomic.get_all_name_facts pnode))) 
                                (* a list of facts ((name * trm) list) which fits class c*)
                                |> map fst (* project only facts name*)
                                |> (fn x => (Class.get_name cls, x))
                              )
                   ) (* cname * name list*)
                 (GoalTyp.get_facts gtyp);
             val if_empty = (map snd cname_factList) 
                                  |> (fn x => case x of [] => true | _ => false)
           in
             if if_empty (* check if all class are binded with facts*)
             then
               (let 
                  val link = GoalTyp.get_link gtyp (* GNode.get_fact_names |> StrName.NSet.list_of *)
                  fun match_link_item (lkey as (fname, (cname1, cname2))) dl = 
                    let
                      fun get_facts_term_list cname =
                         GNode.get_fact_names cname1 gnode 
                         |> StrName.NSet.list_of 
                         |> map 
                              (fn i => (Atomic.lookup_fact pnode i
                                        |> (fn x => case x of NONE  => raise link_match_exp ("can't find matched facts", Link.get_name link)
                                                          | (SOME y) => y)))
                         |> map Prover.trm_of_thm
                      val fact_l1 = get_facts_term_list cname1
                      val fact_l2 =  get_facts_term_list cname2
                    in
                      link_data_ll_match fname ctxt fact_l1 fact_l2 dl
                    end  
                  fun strip_some (SOME x) = x
                  val if_link_match = 
                    map (fn x => match_link_item x (Link.get_item x link |> strip_some)) (Link.get_keys link) (* a list of bool *)
                    |> filter (fn x => x = false)
                    |> (fn x => case x of [] => true | _ => false)
                in
                  if if_link_match  (* check link *)
                  then
                    GNode.mk_goal_no_facts (Atomic.get_pnode_name pnode) 
                      |> fold GNode.add_facts (map (fn (x,y) => (x,StrName.NSet.of_list y)) cname_factList)
                      |> GNode.set_parent gnode |> SOME
                  else NONE
                end)
             else NONE
           end)
      else NONE
    end

    fun match gtyp gnode pnode =  case (lift gtyp gnode pnode) of NONE => false | _=> true
(*
  exception quick_eval_exp
  fun qfold f_exp d f l b  =  
      fold 
        (fn x => (fn y => 
            let val ret = f x y in 
              if f_exp (ret) then raise quick_eval_exp else ret 
         end)) l b
  handle quick_eval_exp => d;
*)

  structure Sharing =
  struct
   structure GoalTyp = GoalTyp.Sharing
   structure Link = Link.Sharing
   structure Class = Class.Sharing
   structure GoalTypData = GoalTypData.Sharing
   structure Prover = Prover.Sharing
   structure MatchParam = MatchParam.Sharing
  end 
end (* structure *)


