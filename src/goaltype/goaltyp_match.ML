signature GOALTYP_MATCH =
sig
  structure GoalTyp : GOAL_TYP 
  structure Atomic : ATOMIC

  exception lfmatch_exp of string * F.name (* links *)
  exception cfmatch_exp of string * F.name (* classes *)

  val class_fmathcher_tab : (GoalTyp.Link.Class.GTData.data list -> GoalTyp.Link.Class.GTData.GProver.term -> bool) F.NTab.T  
  val link_fmatcher_tab :  (GoalTyp.Link.Class.GTData.data list
                         -> (GoalTyp.Link.Class.T * GoalTyp.Link.Class.T) 
                         -> bool) 
                      GoalTyp.Link.linkTbl 

  val cfmatch : F.name -> GoalTyp.Link.Class.GTData.data list -> GoalTyp.Link.Class.GTData.GProver.term -> bool
  val lfmatch : GoalTyp.Link.lkey -> GoalTyp.Link.Class.GTData.data list
                         -> (GoalTyp.Link.Class.T * GoalTyp.Link.Class.T) -> bool

  val match : GoalTyp.T -> GNode.T -> Atomic.pplan -> bool
  val lift : GoalTyp.T -> GNode.T -> Atomic.pnode -> GNode.T option
 

end (* signature *)

functor GTMatchFun (GoalTyp : GOAL_TYP, Atomic : ATOMIC) : GT_MATCH =
struct

  structure GoalTyp = GoalTyp;
  structure Atomic = Atomic;

  exception lfmatch_exp of string * F.name (* links *)
  exception cfmatch_exp of string * F.name (* classes *)

  val class_fmathcher_tab = F.NTab.T.empty (* FIXME: add matcher *)
  val link_fmatcher_tab =  GoalTyp.Link.linkTbl.empty (* FIXME: add matcher *)

  fun cfmatch fname = F.NTab.get fmathcher_tab fname
  handle _ => raise fmatch_exp ("class not supported",fname);

  fun lfmatch lkey = GoalTyp.Link.linkTbl.get link_fmatcher_tab lkey
  handle => raise lmatch_exp ("link not supported",lname);

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

  fun match_class class trm = 
    let 
      fun matches (x :: xs) fname =  if cfmatch fname x trm then true else matches xs
        | matches [] fname = false
    in
      map (fn name => matches (GoaTyp.Link.Class.get_item name class) name) (GoaTyp.Link.Class.get_keys class)
      |> filter (fn x => x = false)
      |> fn x => (case x of [] => true | _ => false)
    end

  exception match_exp of string
  (* match link with a list of class *)
  fun match_link link class_list =
    let
      fun get_class cname = 
        let val ret_l = filter (fn cls => C.name_eq (GoalTyp.Link.Class.get_name cls * cname)) class_list in
                  if List.length ret_l > 1 then raise match_exp "classes with the same name"
                  else
                    (case ret_t of [] => NONE
                                 | [x] => SOME x)
        end;
      fun matches (x :: xs) (l, c1, c2) = 
          let 
            val cl1 = get_class c1;
            val cl2 = get_class c2;
            val if_cls_exists = case cl1 of NONE => false | _ => (case cl2 of NONE => false | _ => true);
            fun strip_SOME (SOME x) = x
          in
            if if_cls_exists then 
              if lfmatch (l, c1, c2) x (strip_SOME cl1, strip_SOME cl2) then true else matches xs
            else false
          end
        | matches [] fname = false
    in
      map (fn lkey => matches (GoaTyp.Link.get_item lkey link) lkey) (GoaTyp.Link.get_keys link)
      |> filter (fn x => x = false)
      |> fn x => (case x of [] => true | _ => false)
    end
  

  fun lift gtyp gnode pnode =       
    let
      val gterm = Atomic.get_pnode_goal pnode (* fact of pnode goal *) (* FIXME: what happen if in the middle of proof *)
                  |> GoalTyp.Link.Class.GTData.GProver.concl_of_thm; (* goal term *)
    in
      if match_class (GoalTyp.get_gclass gtyp) gterm (* check if the goal class fits*) 
        then 
          (let 
             val cname_facts_list = 
               map (fn c => (filter (fn y => snd y |> match_class c) 
                              (map (fn x => (fst x, GoalTyp.Link.Class.GTData.GProver.trm_of_thm (snd x))) 
                                (get_all_name_facts pnode))) (* facts list : (name * trm) list*)
                              (* a list of facts ((name * trm) list) which fits class c*)
                     |> fn x => (GoalTyp.Link.Class.get_name c, fst x)) (* cname * name list*)
                 (GoaTyp.get_facts gtyp);
             val if_facts_class = (map snd cname_facts_list) 
                                  |> filter (fn x => x = false) 
                                  |> (fn x => case x of [] => true | _ => false)
           in
             if if_facts_class (* check if all class are binded with facts*)
             then
               (if match_link (GoalTyp.get_link gtyp) (GoalTyp.get_facts gtyp) (* check link *)
                then
                  GNode.mk_goal_no_facts (get_pnode_name pnode) 
                    |> fold GNode.add_facts (map (fn x => snd |> StrName.NSet.of_list) cname_facts_list)
                    |> GNode.set_parent gnode |> SOME
                else NONE)
             else NONE
           end)
      else NONE
    end


end (* structure *)


