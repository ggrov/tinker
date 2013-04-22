(* to hold class features  *)

signature CLASS = 
sig
  type general_term 
  type position

  datatype feature = 
      Int of int
    | String of string (* not in paper, but simplifies across TPs (e.g. to hold function name) *)
    | Term of general_term(*must be generalised beyond TP system *)         
    | Position of position
    | Bool of bool
    | DVar of StrName.name (* variable: not used at the moment but may be required *)
  
  type data
  type T
  
  val id : T
  val bottom : T
  val top : T
  

  val get_data : StrName.name -> T -> data
  val update_data : StrName.name -> (data -> data) -> T -> T
  val set_data: StrName.name -> data -> T -> T
  val del_data : StrName.name -> T -> T

(*
  val data_ord : (data * data) -> order option
  val data_inter : (data * data) -> data
*)
  val data_union : (data * data) -> data 
  val data_inter : (data * data) -> data 
 
  val ord : T * T -> order option (* partial order, curently it is only dummy *)
  val union : T * T -> T (* GG comment: not sure if this is possible - what is the union of two shapes? *)
  val inter : T * T -> T (* GG comment: same as above *)
end;


(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *) 

(* TODO: generalise, by creating a term structure and a functor over this *)
functor ClassFun (GT: G_TERM) : CLASS = 
struct
  type general_term = GT.term
  type position =  GT.position

  datatype feature = 
      Int of int
    | String of string (* not in paper, but simplifies across TPs (e.g. to hold function name) *)
    | Term of general_term(*must be generalised beyond TP system *)         
    | Position of position
    | Bool of bool
    | DVar of StrName.name (* variable: not used at the moment but may be required *)
  
  fun not_ord x = case x of (SOME EQUAL) => SOME EQUAL
                                | _ => NONE

  fun compare_feature ((Int a), (Int b)) = SOME(Int.compare (a, b))
    | compare_feature ((String a), (String b)) = not_ord (SOME(String.compare (a,b)))
    | compare_feature ((Term a), (Term b)) = not_ord (SOME(GT.compare_term (a,b)))
    | compare_feature ((Position a), (Position b)) = SOME(GT.compare_position (a,b))
    | compare_feature ((Bool a), (Bool b)) =  if a = b then SOME EQUAL else NONE
    | compare_feature ((DVar a), (DVar b)) = not_ord (SOME(String.compare (a,b)))
    | compare_feature (_,_) = NONE

  fun dummy_compare (_,_) = NONE
  
  structure type_feature_set : TYPE_SET =
  struct
    type T = feature
    val compare = compare_feature
  end (*struct*)

  structure feature_set = NaiveSet_FUN (type_feature_set);

  structure type_feature_set_set : TYPE_SET =
  struct
    type T = feature_set.set
    fun compare (a,b) = 
      let val c = feature_set.union (a,b) in 
        if (feature_set.size c = feature_set.size a) 
        then 
          (if feature_set.size b = feature_set.size c then SOME EQUAL else NONE) 
        else NONE
      end
  end (*struct*)
 
  structure feature_set_set = NaiveSet_FUN(type_feature_set_set);
  
  type data = feature_set_set.set;

  type T = data StrName.NTab.T;

(* most general \<top> ,  val top = ;*)
(* empty class \<bottom> *)
  val bottom =  StrName.NTab.empty; (* is this correct? doesn't this always succed? *)
  val top =  StrName.NTab.empty; 
  val id = bottom;

(*********************************************************
*   Functions for 'feature set'
**********************************************************)
  val feature_set_union = feature_set.union
  val feature_set_inter = feature_set.inter

(*********************************************************
*   Functions for 'data'
**********************************************************)
  val data_union = feature_set_set.union
  val data_inter = feature_set_set.inter

(*********************************************************
*   Functions for 'name --> data'
**********************************************************)
  exception class_feature_exp of StrName.name * data StrName.NTab.T 
  fun get_data name_str class = case StrName.NTab.lookup class name_str
                                        of NONE => raise class_feature_exp (name_str, class)
                                        | SOME x => x

  fun update_data name_str f class = StrName.NTab.update (name_str, f(get_data name_str class))  class
  fun set_data name_str d class = StrName.NTab.update (name_str, d)  class
  fun del_data name_str class = StrName.NTab.delete name_str  class

(*do we really need to compare feature set set ?*)
  val ord  = dummy_compare

  fun union ((a : T), (b : T)) = 
    let 
      val la = StrName.NTab.keys a; 
      fun merge (name : StrName.name) (n : T) = 
        let 
          val item_n = StrName.NTab.lookup n name;
          val item_a = StrName.NTab.get a name
        in 
          case item_n of (SOME d) => StrName.NTab.update (name, data_union (d, item_a)) n
             | _ => StrName.NTab.ins (name, item_a) n
        end
    in
      fold merge la b
    end

  fun inter ((a : T), (b : T)) = 
    let 
      val la = StrName.NTab.keys a; 
      fun merge_set (name : StrName.name) (n : T) = 
        let 
          val item_n = StrName.NTab.lookup n name;
          val item_a = StrName.NTab.get a name
        in 
          case item_n of (SOME d) => ( 
            let val int_ret =  data_inter (d, item_a) in 
              (if feature_set_set.is_empty int_ret then StrName.NTab.delete name n
               else StrName.NTab.update (name, int_ret) n)
              end)
             | _ => n
         end
    in
      fold merge_set la b
    end

end; (* struct *)

structure Class = ClassFun (General_Term);
