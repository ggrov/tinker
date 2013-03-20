(* combine data to allow substitutions on both vertex and edge *)
structure GraphSubstData
= struct

  datatype vdata = RT of RTechn.T
                 | GN of GNode.T
                 (* | GNList of GNode.T list *)
                 | RVar of string (* variable of rtechn *)
                 | GVar of string (* variable of goalnode *)

  datatype edata = GT of GoalTyp.T
                 | EVar of string (* variable of goalnode *)

  datatype data = EData of edata | VData of vdata

  (* ordering for vertex data *)
  fun vdata_ord (RVar v1,RVar v2) = String.compare (v1,v2)
    | vdata_ord (RVar v1,RVar v2) = String.compare (v1,v2)
    | vdata_ord (RVar _,_) = LESS
    | vdata_ord (GVar _,_) = LESS
    | vdata_ord (GN _, RT _) = LESS
    | vdata_ord (RT _, GN _) = GREATER
    | vdata_ord (GN g1, GN g2) = GNode.ord (g1,g2)
    | vdata_ord (RT r1, RT r2) = RTechn.ord (r1,r2);
  fun vdata_eq (xy as (x, y)) = 
      (case vdata_ord xy of EQUAL => true
          | _ => false);

  fun edata_ord (EVar v1,EVar v2) = String.compare (v1,v2)
    | edata_ord (EVar v1,_) = LESS
    | edata_ord (W _,EVar _) = GREATER
    | edata_ord (W w1,W w2) = Wire.ord (w1,w2)
  fun edata_eq (xy as (x, y)) = 
      (case edata_ord xy of EQUAL => true
          | _ => false);

  fun data_ord (EData e1,EData e2) = edata_ord (e1,e2)
   |  data_ord (EData _,VData _) = LESS
   |  data_ord (VData _,EData _) = GREATER
   |  data_ord (VData v1,VData v2) = vdata_ord (v1,v2);
  fun data_eq (xy as (x, y)) = 
      (case data_ord xy of EQUAL => true
          | _ => false);

  type subst = data StrName.NTab.T;
  val empty_subst = StrName.NTab.empty;
  fun compose_subst (u1,u2) = (StrName.NTab.merge_joint data_eq u1 u2);

end;


