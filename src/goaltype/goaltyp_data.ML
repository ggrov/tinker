structure GT_Name = G;

signature GT_DATA =
sig

  type general_term
  type position

  datatype feature = 
      Int of int
    | String of string (* not in paper, but simplifies across TPs (e.g. to hold function name) *)
    | Term of general_term(*must be generalised beyond TP system *)         
    | Position of position
    | Bool of bool
    | DVar of GT_Name.name (* variable: not used at the moment but may be required *)
  
  type data (* list/set of list/set of data *)
  
  val data_union : (data*data) -> data
  val data_inter: (data*data) -> data
  
  val is_empty : data -> bool

  val to_list : data -> feature list list
  val from_list : feature list list -> data
  val from_single_list : feature list -> data

end (* signature *)

functor GTDataFun (GTREM: G_TERM) =
struct

  type general_term = GTREM.term
  type position =  GTREM.position

  datatype feature = 
      Int of int
    | String of string (* not in paper, but simplifies across TPs (e.g. to hold function name) *)
    | Term of general_term(*must be generalised beyond TP system *)         
    | Position of position
    | Bool of bool
    | DVar of GT_Name.name (* variable: not used at the moment but may be required *)

  fun not_ord x = case x of (SOME EQUAL) => SOME EQUAL
                                | _ => NONE

  fun compare_feature ((Int a), (Int b)) = SOME(Int.compare (a, b))
    | compare_feature ((String a), (String b)) = not_ord (SOME(String.compare (a,b)))
    | compare_feature ((Term a), (Term b)) = not_ord (SOME(GTREM.compare_term (a,b)))
    | compare_feature ((Position a), (Position b)) = SOME(GTREM.compare_position (a,b))
    | compare_feature ((Bool a), (Bool b)) =  if a = b then SOME EQUAL else NONE
    | compare_feature ((DVar a), (DVar b)) = not_ord (SOME(GT_Name.name_ord (a,b)))
    | compare_feature (_,_) = NONE


  structure type_feature_set : TYPE_SET =
  struct
    type T = feature
    val compare = compare_feature
  end (*struct*)

  structure feature_set = NaiveSetFun (type_feature_set);

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
 
  structure feature_set_set = NaiveSetFun(type_feature_set_set);
  
  type data = feature_set_set.set;

  type T = data GT_Name.NTab.T;

  val id  =  GT_Name.NTab.empty; (* is this correct? doesn't this always succed? *)

  (* May not be useful, just keep them*)
  val feature_set_union = feature_set.union
  val feature_set_inter = feature_set.inter
  val data_union = feature_set_set.union
  val data_inter = feature_set_set.inter
  val is_empty = feature_set_set.is_empty

  val to_list = feature_set_set.to_list
  val from_list = feature_set_set.from_list
  val from_single_list = feature_set_set.from_single_list


end (* structure *)

structure DB_GTData = GTDataFun(General_Term);
structure GTData: GT_DATA = DB_GTData;

