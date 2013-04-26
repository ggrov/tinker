(* to hold class features  *)

signature CLASS = 
sig
  type data
  type T

  val top : T
  
  val get_data : GT_Name.name -> T -> data
  val rename_data : GT_Name.name -> GT_Name.name -> T -> T option 
  val set_data: GT_Name.name -> data -> T -> T
  val del_data : GT_Name.name -> T -> T

  val ord : T * T -> order option (* partial order, curently it is only dummy *)

  (* shape is the basic unit*)
  type classTab
  val empty_classtab : classTab
  val update_class :  (GT_Name.name * T) -> classTab -> classTab
  val remove_class : GT_Name.name -> classTab -> classTab
  (*old name -> new name...None if name crushes*)
  val rename_class : GT_Name.name -> GT_Name.name -> classTab -> classTab option 
  val get_class_by_name : classTab -> GT_Name.name -> T

  val list_of_class_name : classTab -> GT_Name.name list
  val if_name_fresh : classTab -> GT_Name.name -> bool
  

end;


(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *) 

(* TODO: generalise, by creating a term structure and a functor over this *)
structure DB_Class = 
struct
  
  fun dummy_compare (_,_) = NONE
  type data = GTData.data
  type T = data GT_Name.NTab.T;

  type classTab = T GT_Name.NTab.T;

  val top =  GT_Name.NTab.empty; 
  val id = GT_Name.NTab.empty;


(*********************************************************
*   Functions for 'name --> data'
**********************************************************)
  exception class_feature_exp of GT_Name.name * data GT_Name.NTab.T 
  fun get_data name_str class = case GT_Name.NTab.lookup class name_str
                                        of NONE => raise class_feature_exp (name_str, class)
                                        | SOME x => x
  fun set_data name_str d class = GT_Name.NTab.update (name_str, d)  class
  fun del_data name_str class = GT_Name.NTab.delete name_str class
  val rename_data = GT_Name.NTab.try_rename1

(*do we really need to compare feature set set ?*)
  val ord  = dummy_compare

  fun union ((a : T), (b : T)) = 
    let 
      val la = GT_Name.NTab.keys a; 
      fun merge (name : GT_Name.name) (n : T) = 
        let 
          val item_n = GT_Name.NTab.lookup n name;
          val item_a = GT_Name.NTab.get a name
        in 
          case item_n of (SOME d) => GT_Name.NTab.update (name, GTData.data_union (d, item_a)) n
             | _ => GT_Name.NTab.ins (name, item_a) n
        end
    in
      fold merge la b
    end

  fun inter ((a : T), (b : T)) = 
    let 
      val la = GT_Name.NTab.keys a; 
      fun merge_set (name : GT_Name.name) (n : T) = 
        let 
          val item_n = GT_Name.NTab.lookup n name;
          val item_a = GT_Name.NTab.get a name
        in 
          case item_n of (SOME d) => ( 
            let val int_ret =  GTData.data_inter (d, item_a) in 
              (if GTData.is_empty int_ret then GT_Name.NTab.delete name n
               else GT_Name.NTab.update (name, int_ret) n)
              end)
             | _ => n
         end
    in
      fold merge_set la b
    end
  

  val empty_classtab = GT_Name.NTab.empty;
  val update_class  =  GT_Name.NTab.update;
  val remove_class = GT_Name.NTab.delete;
  val get_class_by_name = GT_Name.NTab.get;
  val list_of_class_name = GT_Name.NTab.keys
  fun if_name_fresh name tbl= GT_Name.NTab.contains name tbl |> not
  val rename_class =   GT_Name.NTab.try_rename1


end; (* struct *)

structure Class: CLASS = DB_Class;

