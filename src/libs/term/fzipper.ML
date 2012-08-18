(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *) 
(*  Title:      libs/fzipper.ML
    Author:     Lucas Dixon, University of Edinburgh
                lucas.dixon@ed.ac.uk
    Date:       2 Jun 2008
*)
(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *) 
(*  DESCRIPTION:
    A notion roughly based on Huet's Zippers for Flattened Isabelle terms.
*)   

(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *)

(* abstract term for no more than pattern matching *)
signature ABSTRACT_FTRM = 
sig
type typ   (* types *)
type aname (* abstraction names *)
type fname (* parameter/free variable names *)
type cname (* constant names *)
type vname (* meta variable names *)
type bname (* bound var name *)
datatype atomic = 
         aConst of cname * typ
       | aBound of bname
       | aVar of vname * typ
       | aFree of fname * typ
       | aAbs of aname * typ * T
and T = 
    App of atomic * T list
  | Atomic of atomic;
end;

structure IsabelleFTrmWrap : ABSTRACT_FTRM = 
struct 
open FTerm
type typ = Term.typ
type aname = string; (* abstraction names *)
type fname = string; (* parameter/free variable names *)
type cname = string; (* constant names *)
type vname = string * int; (* meta variable names *)
type bname = int; (* bound var name *)
end;


(* Concrete version for the Trm structure *)
signature FTRM_CTXT_DATA = 
sig
  structure Trm : ABSTRACT_FTRM
  datatype dtrm = Abs of Trm.aname * Trm.typ
                | AppHd of Trm.T list
                | AppArg of Trm.atomic * ((Trm.T list) * (Trm.T list));
  val apply : dtrm -> Trm.T -> Trm.T
  val eq_dtrm_pos : dtrm * dtrm -> bool
end;

(* A trm context = list of derivatives *)
signature FTRM_CTXT =
sig
  structure D : FTRM_CTXT_DATA
  structure Trm : ABSTRACT_FTRM
  sharing D.Trm = Trm

  type T = D.dtrm list

  val empty : T
  val is_empty : T -> bool

  val eq_path : T * T -> bool

  val add_outerctxt : T -> T -> T

  val apply : T -> Trm.T -> Trm.T

  val nty_ctxt : T -> (Trm.aname * Trm.typ) list;
  val ty_ctxt : T -> Trm.typ list;

  val depth : T -> int;
  val map : (D.dtrm -> D.dtrm) -> T -> T
  val fold : (D.dtrm -> 'a -> 'a) -> T -> 'a -> 'a

end;

(* A zipper = a term looked at, at a particular point in the term *)
signature FZIPPER =
sig
  structure C : FTRM_CTXT
  structure Trm : ABSTRACT_FTRM
  sharing C.Trm = Trm

  type T

  val mktop : Trm.T -> T
  val goto_top : T -> T
  val at_top : T -> bool
  val mk : (Trm.T * C.T) -> T
  val set_trm : Trm.T -> T -> T
  val set_ctxt : C.T -> T -> T

  val split : T -> T * C.T
  val add_outerctxt : C.T -> T -> T

  val ctxt : T -> C.T
  val trm : T -> Trm.T

  val nty_ctxt : T -> (Trm.aname * Trm.typ) list;
  val ty_ctxt : T -> Trm.typ list;

  val depth_of_ctxt : T -> int;
  val map_on_ctxt : (C.D.dtrm -> C.D.dtrm) -> T -> T
  val fold_on_ctxt : (C.D.dtrm -> 'a -> 'a) -> T -> 'a -> 'a

  (* searching through a zipper *)
  datatype zsearch = Here of T | LookIn of T;
  (* lazily search through the zipper *)
  val lzy_search : (T -> zsearch list) -> T -> T Seq.seq
  (* lazy search with folded data *)
  val pf_lzy_search : ('a -> T -> ('a * zsearch list)) 
                      -> 'a -> T -> T Seq.seq
  (* zsearch list is or-choices *)
  val searchfold : ('a -> T -> (('a * zsearch) list)) 
                      -> 'a -> T -> ('a * T) Seq.seq
  (* limit function to the current focus of the zipper, 
     but give function the zipper's context *)
  val limit_pcapply : (C.T -> T -> ('a * T) Seq.seq) 
                      -> T -> ('a * T) Seq.seq
  val limit_apply : (T -> T Seq.seq) -> T -> T Seq.seq
  val limit_capply : (C.T -> T -> T Seq.seq) -> T -> T Seq.seq

  (* moving around zippers with option types *)
  val omove_up : T -> T option
  val omove_up_abs : T -> T option
  val omove_up_app : T -> T option
  val omove_up_app_hd : T -> T option
  val omove_up_app_arg : T -> T option
  val omove_up_app_hd_or_abs : T -> T option
  val omove_up_app_arg_or_abs : T -> T option

  val omove_down_abs : T -> T option
  val omove_down_app_hd : T -> T option
  val omove_down_app_arg_i : int -> T -> T option
  val omove_down_app_arg : T -> (T list) option
  val omove_down_app : T -> (T * T list) option

  (* moving around zippers, raising exceptions *)
  exception move_exp of string * T
  val move_up : T -> T
  val move_up_abs : T -> T
  val move_up_app : T -> T
  val move_up_app_hd : T -> T
  val move_up_app_arg : T -> T
  val move_up_app_hd_or_abs : T -> T
  val move_up_app_arg_or_abs : T -> T

  val move_down_abs : T -> T
  val move_down_app_hd : T -> T
  val move_down_app_arg : T -> T list
  val move_down_app_arg_i : int -> T -> T
  val move_down_app : T -> (T * T list)
end;


(* Zipper data for an generic trm *)
functor FTrmCtxtDataFUN(Trm : ABSTRACT_FTRM) 
: FTRM_CTXT_DATA 
= struct

  exception not_atomic_ftrm_exp of string;

  structure Trm = Trm;

  (* a dtrm is, in McBridge-speak, a differentiated term. It represents
  the different ways a term can occur within its datatype constructors *)
  datatype dtrm = Abs of Trm.aname * Trm.typ
                | AppHd of Trm.T list
                | AppArg of Trm.atomic * ((Trm.T list) * (Trm.T list));

  (* apply a dtrm to a term, ie put the dtrm above it, building context *)
  fun apply (Abs (s,ty)) t = Trm.Atomic (Trm.aAbs (s,ty,t))
    | apply (AppHd args) (Trm.Atomic a) = Trm.App (a, args)
    | apply (AppHd args) _ = raise not_atomic_ftrm_exp "TrmCtxtDataFUN:apply"
    | apply (AppArg (a,(l,r))) t = Trm.App (a, l @ [t] @ r);

  fun eq_dtrm_pos (Abs _, Abs _) = true
    | eq_dtrm_pos (AppHd _, AppHd _) = true
    | eq_dtrm_pos (AppArg (_,(l,r)), AppArg (_,(l2,r2))) = 
      (length l = length l2 andalso length r = length r2)
    | eq_dtrm_pos _ = false;

end;


(* functor for making term contexts given term data *)
functor FTrmCtxtFUN(D : FTRM_CTXT_DATA) 
 : FTRM_CTXT =
struct 
  structure D = D;
  structure Trm = D.Trm;

  type T = D.dtrm list;

  val empty = [];
  val is_empty = List.null;

  fun eq_path ([], []) = true
    | eq_path ([], _::_) = false
    | eq_path ( _::_, []) = false
    | eq_path (h::t, h2::t2) = 
      D.eq_dtrm_pos(h,h2) andalso eq_path (t, t2);

  (* add context to outside of existing context *) 
  fun add_outerctxt ctop cbottom = cbottom @ ctop; 

  (* mkterm : zipper -> trm -> trm *)
  val apply = Basics.fold D.apply;
  
  (* named type context *)
  val nty_ctxt = List.foldr (fn (D.Abs nty,ntys) => nty::ntys
                             | (_,ntys) => ntys) [];
  (* type context *)
  val ty_ctxt = List.foldr (fn (D.Abs (_,ty),tys) => ty::tys
                           | (_,tys) => tys) [];

  val depth = length : T -> int;

  val map = List.map : (D.dtrm -> D.dtrm) -> T -> T

  val fold = Basics.fold : (D.dtrm -> 'a -> 'a) -> T -> 'a -> 'a;

end;

(* zippers in terms of term contexts *)
functor FZipperFUN(C : FTRM_CTXT) 
 : FZIPPER
= struct 

  structure C = C;
  structure D = C.D;
  structure Trm = C.Trm;

  datatype T = Zpr of Trm.T * C.T;

  fun mktop t = Zpr (t, C.empty);

  val mk = Zpr;
  fun set_trm t2 (Zpr (_,c)) = (Zpr (t2,c));
  fun set_ctxt c2 (Zpr (t,_)) = (Zpr (t,c2))

  fun goto_top (z as Zpr (t,c)) = 
      if C.is_empty c then z else (Zpr (C.apply c t, C.empty));

  fun at_top (Zpr (_,c)) = C.is_empty c;

  fun split (Zpr (t,c)) = ((Zpr (t,C.empty)), c : C.T) 
  fun add_outerctxt c (Zpr(t,c2)) = (Zpr (t, C.add_outerctxt c c2)) : T

  fun ctxt (Zpr(t,c)) = c;
  fun trm (Zpr(t,c)) = t;

  val nty_ctxt = C.nty_ctxt o ctxt;
  val ty_ctxt = C.ty_ctxt o ctxt;

  val depth_of_ctxt = C.depth o ctxt;
  fun map_on_ctxt f (Zpr(t,c)) = Zpr(t,C.map f c);
  fun fold_on_ctxt f = C.fold f o ctxt;

  fun omove_up (Zpr (t,(d::c))) = SOME (Zpr (D.apply d t, c))
    | omove_up (z as Zpr (_,[])) = NONE;
  fun omove_up_abs (Zpr (t,((d as D.Abs _)::c))) = SOME ((Zpr (D.apply d t, c)) : T)
    | omove_up_abs z = NONE;
  fun omove_up_app (Zpr (t,(d as D.AppHd _)::c)) = SOME (Zpr (D.apply d t, c))
    | omove_up_app (Zpr (t,(d as D.AppArg _)::c)) = SOME (Zpr (D.apply d t, c))
    | omove_up_app z = NONE;
  fun omove_up_app_hd (Zpr (t,(d as D.AppHd _)::c)) = SOME (Zpr (D.apply d t, c))
    | omove_up_app_hd z = NONE;
  fun omove_up_app_arg (Zpr (t,(d as D.AppArg _)::c)) = SOME (Zpr (D.apply d t, c))
    | omove_up_app_arg _ = NONE;
  fun omove_up_app_hd_or_abs (Zpr (t,(d as D.AppHd _)::c)) = SOME (Zpr (D.apply d t, c))
    | omove_up_app_hd_or_abs (Zpr (t,(d as D.Abs _)::c)) = SOME (Zpr (D.apply d t, c))
    | omove_up_app_hd_or_abs z = NONE;
  fun omove_up_app_arg_or_abs (Zpr (t,(d as D.AppArg _)::c)) = SOME (Zpr (D.apply d t, c))
    | omove_up_app_arg_or_abs (Zpr (t,(d as D.Abs _)::c)) = SOME (Zpr (D.apply d t, c))
    | omove_up_app_arg_or_abs _ = NONE;

  fun omove_down_abs (Zpr (Trm.Atomic(Trm.aAbs(s,ty,t)),c)) = SOME (Zpr (t,(D.Abs(s,ty))::c))
    | omove_down_abs _ = NONE;
  fun omove_down_app_hd (Zpr (Trm.App(a,args),c)) = SOME (Zpr (Trm.Atomic a,(D.AppHd args)::c))
    | omove_down_app_hd _ = NONE;

  fun omove_down_app_arg (z as Zpr (t as Trm.App(a,args),c)) = 
      let fun move_down_args l (h::r) zs = 
              move_down_args l r ((Zpr(h,(D.AppArg(a,(l,r))::c)))::zs)
            | move_down_args l [] zs = zs; 
      in SOME (rev (move_down_args [] args [])) end
    | omove_down_app_arg _ = NONE;
  fun omove_down_app_arg_i i (Zpr (Trm.App(a,l),c)) = 
      (case (Library.chop i l) 
        of (l,(h::r)) => 
           SOME (Zpr (h,(D.AppArg(a,(l,r)))::c))
         | (_,_) => NONE)
    | omove_down_app_arg_i i _ = NONE;
  fun omove_down_app (z as Zpr (t as Trm.App(a,args),c)) = 
      let fun move_down_args l (h::r) zs = 
              move_down_args l r ((Zpr(h,(D.AppArg(a,(l,r))::c)))::zs)
            | move_down_args l [] zs = zs; 
      in SOME ((Zpr (Trm.Atomic a,(D.AppHd args)::c)),(rev (move_down_args [] args []))) end
    | omove_down_app _ = NONE;

  exception move_exp of string * T
  fun do_move s f z = (case f z of NONE => raise move_exp (s,z) | SOME z2 => z2)
  val move_up = do_move "move_up" omove_up;
  val move_up_abs = do_move "move_up_abs" omove_up_abs;
  val move_up_app = do_move "move_up_app" omove_up_app;
  val move_up_app_hd = do_move "move_up_app_hd" omove_up_app_hd;
  val move_up_app_arg = do_move "move_up_app_arg" omove_up_app_arg;
  val move_up_app_hd_or_abs = do_move "move_up_app_hd_or_abs" omove_up_app_hd_or_abs;
  val move_up_app_arg_or_abs = do_move "move_up_app_arg_or_abs" omove_up_app_arg_or_abs;

  val move_down_abs = do_move "move_down_abs" omove_down_abs;
  val move_down_app = do_move "move_down_app" omove_down_app;
  val move_down_app_hd = do_move "move_down_app_hd" omove_down_app_hd;
  val move_down_app_arg = do_move "move_down_app_arg" omove_down_app_arg;
  val move_down_app_arg_i = do_move "move_down_app_arg_i" o omove_down_app_arg_i;


  (* Note: interpretted as being examined depth first *)
  datatype zsearch = Here of T | LookIn of T;

  fun lzy_search fsearch = 
      let 
        fun lzyl [] () = NONE
          | lzyl ((Here z) :: more) () = SOME(z, Seq.make (lzyl more))
          | lzyl ((LookIn z) :: more) () =
            (case lzy z
              of NONE => NONE
               | SOME (hz,mz) => 
                 SOME (hz, Seq.append mz (Seq.make (lzyl more))))
        and lzy z = lzyl (fsearch z) ()
      in Seq.make o lzyl o fsearch end;

  (* path folded lazy search - the search list is defined in terms of
  the path passed through: the data a is updated with every zipper
  considered *)
  fun pf_lzy_search fsearch a0 z = 
      let 
        fun lzyl a [] () = NONE
          | lzyl a ((Here z) :: more) () = SOME(z, Seq.make (lzyl a more))
          | lzyl a ((LookIn z) :: more) () =
            (case lzy a z
              of NONE => lzyl a more ()
               | SOME(hz,mz) => SOME(hz, Seq.append mz (Seq.make(lzyl a more))))
        and lzy a z = 
            let val (a2, slist) = (fsearch a z) in lzyl a2 slist () end

        val (a,slist) = fsearch a0 z
      in Seq.make (lzyl a slist) end;

  (* Note: depth first over zsearch results *)
  fun searchfold fsearch a0 z = 
      let 
        fun lzyl [] () = NONE
          | lzyl ((a, Here z) :: more) () = 
            SOME((a,z), Seq.make (lzyl more))
          | lzyl ((a, LookIn z) :: more) () =
            (case lzyl (fsearch a z) () of 
               NONE => lzyl more ()
             | SOME (z,mz) => SOME (z,Seq.append mz (Seq.make (lzyl more))))
      in Seq.make (lzyl (fsearch a0 z)) end;


  fun limit_pcapply f z = 
      let val (z2,c) = split z
      in Seq.map (apsnd (add_outerctxt c)) (f c z2) end;
  fun limit_capply (f : C.T -> T -> T Seq.seq) (z : T) = 
      let val ((z2 : T),(c : C.T)) = split z
      in Seq.map (add_outerctxt c) (f c z2) end

  val limit_apply = limit_capply o K;

end;

(* now build these for Isabelle terms *)
structure FTrmCtxtData = FTrmCtxtDataFUN(IsabelleFTrmWrap);
structure FTrmCtxt = FTrmCtxtFUN(FTrmCtxtData);
structure FZipper = FZipperFUN(FTrmCtxt);


(* For searching through Zippers below the current focus...
   KEY for naming scheme:    

   td = starting at the top down
   lr = going from left to right
   rl = going from right to left

   bl = starting at the bottom left
   br = starting at the bottom right
   ul = going up then left
   ur = going up then right
   ru = going right then up
   lu = going left then up
*)
signature FZIPPER_SEARCH =
sig
  structure Z : FZIPPER;
  
  val leaves_lr : Z.T -> Z.T Seq.seq
  val leaves_rl : Z.T -> Z.T Seq.seq

  val all_bl_ru : Z.T -> Z.T Seq.seq
  val all_bl_ur : Z.T -> Z.T Seq.seq
  val all_td_lr : Z.T -> Z.T Seq.seq
  val all_td_rl : Z.T -> Z.T Seq.seq
  
end;

functor FZipperSearchFUN(FZipper : FZIPPER) : FZIPPER_SEARCH
= struct

structure Z = FZipper;
structure C = Z.C;
structure D = C.D; 
structure Trm = D.Trm; 

fun sf_leaves_lr z = 
    case Z.trm z 
     of Trm.App _ => [Z.LookIn (Z.move_down_app_hd z)] @ (map Z.LookIn (Z.move_down_app_arg z))
      | Trm.Atomic(Trm.aAbs _) => [Z.LookIn (Z.move_down_abs z)]
      | _ => [Z.Here z];
fun sf_leaves_rl z = 
    case Z.trm z 
     of Trm.App _ => (rev (map Z.LookIn (Z.move_down_app_arg z))) @ [Z.LookIn (Z.move_down_app_hd z)] 
      | Trm.Atomic(Trm.aAbs _) => [Z.LookIn (Z.move_down_abs z)]
      | _ => [Z.Here z];
val leaves_lr = Z.lzy_search sf_leaves_lr;
val leaves_rl = Z.lzy_search sf_leaves_rl;


fun sf_all_td_lr z = 
    case Z.trm z 
     of Trm.App _ => [Z.Here z, Z.LookIn (Z.move_down_app_hd z)]
                     @ (map Z.LookIn (Z.move_down_app_arg z))
      | Trm.Atomic(Trm.aAbs _) => [Z.Here z, Z.LookIn (Z.move_down_abs z)]
      | _ => [Z.Here z];
fun sf_all_td_rl z = 
    case Z.trm z 
     of Trm.App _ => [Z.Here z] @ (rev (map Z.LookIn (Z.move_down_app_arg z)))
                   @ [Z.LookIn (Z.move_down_app_hd z)]
      | Trm.Atomic(Trm.aAbs _) => [Z.Here z, Z.LookIn (Z.move_down_abs z)]
      | _ => [Z.Here z];
fun sf_all_bl_ur z = 
    case Z.trm z 
     of Trm.App _ => [Z.LookIn (Z.move_down_app_hd z), Z.Here z] @ 
                    (map Z.LookIn (Z.move_down_app_arg z))
      | Trm.Atomic(Trm.aAbs _) => [Z.LookIn (Z.move_down_abs z), Z.Here z]
      | _ => [Z.Here z];
fun sf_all_bl_ru z = 
    case Z.trm z 
     of Trm.App _ => [Z.LookIn (Z.move_down_app_hd z)]
                   @ (map Z.LookIn (Z.move_down_app_arg z)) @ [Z.Here z]
      | Trm.Atomic(Trm.aAbs _) => [Z.LookIn (Z.move_down_abs z), Z.Here z]
      | _ => [Z.Here z];

val all_td_lr = Z.lzy_search sf_all_td_lr;
val all_td_rl = Z.lzy_search sf_all_td_rl;
val all_bl_ur = Z.lzy_search sf_all_bl_ru;
val all_bl_ru = Z.lzy_search sf_all_bl_ur;

end;


structure FZipperSearch = FZipperSearchFUN(FZipper);
