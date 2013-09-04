signature GOALTYP_MATCH_SHARING =
sig
  structure GoalTyp: GOAL_TYP_SHARING
  structure Link : LINK_SHARING
  structure Class : CLASS_SHARING
  structure GoalTypData : GOALTYP_DATA_SHARING
  structure Prover : PROVER_SHARING
  structure MatchParam : MATCH_PARAM_SHARING
end

signature GOALTYP_MATCH =
sig
  structure GoalTyp : GOAL_TYP 
  structure Link : LINK
  structure Class : CLASS
  structure GoalTypData : GOALTYP_DATA
  structure Prover : PROVER
  structure MatchParam : MATCH_PARAM
  sharing GoalTypData.Sharing = Link.Sharing.GoalTypData
  sharing GoalTypData.Sharing = Class.Sharing.GoalTypData
  sharing GoalTypData.Sharing = MatchParam.Sharing.GoalTypData
  sharing Link.Sharing = GoalTyp.Sharing.Link
  sharing Class.Sharing = GoalTyp.Sharing.Class
  sharing MatchParam.Sharing.Prover = GoalTypData.Sharing.Prover

  exception class_match_exp of string * C.name
  exception link_match_exp of string * L.name
                     
  val class_match : Class.T -> Prover.context -> Prover.Object -> bool
  val link_match :  F.name -> Prover.context 
                              -> Prover.Object list -> Prover.Object list
                              -> GoalTypData.data list list -> bool

  val match : GNode.T -> GoalTyp.T -> Prover.pnode -> bool (* dummy *)
  val init_lift : GoalTyp.T -> Prover.pnode -> GNode.T option
  val lift : GNode.T -> GoalTyp.T -> Prover.pnode -> GNode.T option
 
  structure Sharing : GOALTYP_MATCH_SHARING
    sharing Sharing.GoalTyp = GoalTyp.Sharing
    sharing Sharing.Link = Link.Sharing
    sharing Sharing.Class = Class.Sharing
    sharing Sharing.GoalTypData = GoalTypData.Sharing
    (*sharing Sharing.Prover = Prover.Sharing*)
    sharing Sharing.MatchParam = MatchParam.Sharing
    sharing Sharing.Prover = Prover.Sharing

end (* signature *)

functor GoalTypMatchFun (structure GoalTyp : GOAL_TYP 
                         structure Link : LINK
                         structure Class : CLASS
                         structure GoalTypData : GOALTYP_DATA
                         structure Prover : PROVER 
                         structure MatchParam : MATCH_PARAM
                         sharing GoalTypData.Sharing = Link.Sharing.GoalTypData
                         sharing GoalTypData.Sharing = Class.Sharing.GoalTypData
                         sharing GoalTypData.Sharing = MatchParam.Sharing.GoalTypData
                         sharing Link.Sharing = GoalTyp.Sharing.Link
                         sharing Class.Sharing = GoalTyp.Sharing.Class
                         sharing Prover.Sharing = GoalTypData.Sharing.Prover
                         sharing Prover.Sharing = MatchParam.Sharing.Prover
                        ) : GOALTYP_MATCH =
struct

  structure GoalTyp = GoalTyp;
  structure Link = Link;
  structure Class = Class;
  structure GoalTypData = GoalTypData;
  structure Prover = Prover;
  structure MatchParam = MatchParam;


  exception class_match_exp of string * C.name
  exception link_match_exp of string * L.name


  val class_data_match = MatchParam.class_data_match
  val link_data_match = MatchParam.link_data_match

  fun class_match class ctxt fact = 
    let 
      fun matches data fname = class_data_match fname ctxt fact data 
      fun strip_some (SOME x) = x
    in
      map (fn fname => matches (Class.get_item fname class |> strip_some) fname) (Class.get_keys class)
      |> filter (fn x => x = false)
      |> (fn x => (case x of [] => true | _ => false))
    end

 fun link_match' fname (ctxt : Prover.context) tpl1 tpl2 data =
   let
      fun link_match0 name (t1, t2) = link_data_match name ctxt (t1,t2) data 
      fun merge_pair (x, (y :: ys)) l = merge_pair (x, ys) [(x, y)] @ l
        | merge_pair (x, []) l = l
  in
      map
        (fn x => 
          (filter (fn y => link_match0 fname (x,y)) tpl2 (* filter the matched terms for x in tl2 *)
          |> (fn p => (x,p)))) (* pair them *)
        tpl1
      (* get a list of pair which matches, e.g.[(a,l1)] where a is the term, l1 conatins terms which matches a1
         now we need to filter thoes pairs where l1 is empty. 
         Also we need to change the type from (term * term list) list to (term * term) list *)
      |> filter (fn (x,y) => (case y of [] => false | _ => true))
      |> (fn l => fold merge_pair l [])
      |> (fn x => case x of [] => NONE | _ => SOME x)
    end

  fun link_match fname ctxt tpl1 tpl2 dl= case link_match' fname ctxt tpl1 tpl2 dl of NONE => false | _ => true

  fun lift' gnode gtyp pnode =       
    let
      val concl = Prover.get_pnode_concl pnode 
      val ctxt = Prover.get_pnode_ctxt pnode
    in
      if class_match (GoalTyp.get_gclass gtyp) ctxt (Prover.Concl concl) (* check if the goal class fits*) 
        then 
          (let 
             val cname_factList = (* a list of pair (cname, facts list), *)
               map (fn cls => (
                                (filter 
                                  (fn y => snd y |> class_match cls ctxt)  (* facts list : (name * Fact fact) list*)
                                  (map (fn (x,y) => (x, (Prover.Fact y))) 
                                    (Prover.get_all_named_facts_pair pnode))
                                )
                                (* a list of facts ((name * trm) list) which fits class c*)
                                |> map fst (* project only facts name*)
                                |> (fn x => (Class.get_name cls, x))
                              )
                   )
                 (GoalTyp.get_facts gtyp);
             val if_class_binded = 
               (map snd cname_factList) 
               |> List.exists (fn x => case x of [] => true | _ => false) 
               |> not;
           in
             if if_class_binded (* check if all class are binded with facts*)
             then
               (let 
                  val link = GoalTyp.get_link gtyp (* GNode.get_fact_names |> StrName.NSet.list_of *)
                  fun match_link_item (lkey as (fname, (cname1, cname2))) dl = 
                    let
                      val factsTbl = C.NTab.of_list cname_factList;
                      fun get_facts cname = 
                        C.NTab.get factsTbl cname 
                          |> map (fn i => (Prover.lookup_fact pnode i
                                    |> (fn x => case x of NONE => raise link_match_exp 
                                                                  ("can't find matched facts", Link.get_name link)
                                                        | (SOME y) => y)))
                           |> map (fn x => (Prover.Fact x))
                        handle _ => raise link_match_exp (" No such a class to match Link", cname);
                        val fact_l1 = get_facts cname1;
                        val fact_l2 = get_facts cname2              
                     in
                      link_match fname ctxt fact_l1 fact_l2 dl
                     end(* end of fun match_link_item*);
                    fun strip_some (SOME x) = x;
                    val if_link_match = 
                      map (fn x => match_link_item x (Link.get_item x link |> strip_some)) (Link.get_keys link) (* a list of bool *)
                      |> filter (fn x => x = false)
                      |> (fn x => case x of [] => true | _ => false)
                  in
                    if if_link_match  (* check link *)
                    then
                    GNode.mk_goal_no_facts (Prover.get_pnode_name pnode) 
                      |> fold GNode.add_facts (map (fn (x,y) => (x,StrName.NSet.of_list y)) cname_factList)
                      |> GNode.set_parent' gnode |> SOME
                  else (writeln "NONE due to link"; NONE)
                end)
             else (writeln "NONE due to class";NONE)
           end)
      else (writeln "NONE due to goal class";NONE)
    end
   (* handle _ => NONE*)
    
    fun lift gnode = lift' (SOME gnode) 
    val init_lift = lift' NONE
    fun match _ _ _  = false 
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
   structure MatchParam = MatchParam.Sharing
   structure Prover = Prover.Sharing
  end 
end (* structure *)


