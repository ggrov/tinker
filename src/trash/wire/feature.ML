structure Feature =
struct

  (* to hold feature data - should make a separate data-type *)
  type fdata = string
  val fdata_ord = String.compare;
  val default_fdata = "ignore";  
  fun suc_fdata str = str ^ "0";

  datatype T  = Terms of term list * fdata
              | Strings of StrName.NSet.T * fdata
              | StrCount of (int StrTable.table) * fdata
              | Count of int * fdata
              | Ref of string * fdata 
              | NoData of fdata

  fun get_fdata (Terms (_,fd)) = fd
   |  get_fdata (Strings (_,fd)) = fd
   |  get_fdata (StrCount (_,fd)) = fd
   |  get_fdata (Count (_,fd)) = fd
   |  get_fdata (Ref (_,fd)) = fd
   |  get_fdata (NoData fd) = fd;

  fun upd_fdata f (Terms (fs,fd)) = (Terms (fs,f fd))
   |  upd_fdata f (Strings (ss,fd)) = (Strings (ss,f fd))
   |  upd_fdata f (StrCount (cs,fd)) = (StrCount (cs,f fd))
   |  upd_fdata f (Count (c,fd)) = (Count (c,f fd))
   |  upd_fdata f (Ref (r,fd)) = (Ref (r,f fd))
   |  upd_fdata f (NoData fd) = (NoData (f fd));

  val default_feature = NoData default_fdata;
  type name = T;
  val suc = upd_fdata suc_fdata;
  fun pred f = NONE;

  fun ord (NoData fd1,NoData fd2) = fdata_ord (fd1,fd2)
   |  ord (NoData _,_) = LESS
   |  ord (_,NoData _) = GREATER  
   |  ord (Ref (r1,fd1),Ref (r2,fd2)) = 
        (case fdata_ord (fd1,fd2) of
          EQUAL => String.compare (r1,r2)
        |  v => v)
   |  ord (Ref _,_) = LESS
   |  ord (_,Ref _) = GREATER 
   |  ord (Count (c1,fd1),Count (c2,fd2)) = 
        (case fdata_ord (fd1,fd2) of
          EQUAL => Int.compare (c1,c2)
        |  v => v)
   |  ord (Count _,_) = LESS
   |  ord (_,Count _) = GREATER 
   |  ord (StrCount (str1,fd1),StrCount (str2,fd2)) = 
        (case fdata_ord (fd1,fd2) of
          EQUAL => EQUAL (* fixme *)
        |  v => v)
   |  ord (StrCount _,_) = LESS
   |  ord (_,StrCount _) = GREATER 
   |  ord (Strings (str1,fd1),Strings (str2,fd2)) = 
        (case fdata_ord (fd1,fd2) of
          EQUAL => StrName.NSet.ord(str1,str2)
        |  v => v)
   |  ord (Strings _,_) = LESS
   |  ord (_,Strings _) = GREATER 
   |  ord (Terms (str1,fd1),Terms (str2,fd2)) = 
        (case fdata_ord (fd1,fd2) of
          EQUAL => EQUAL (* fixme *)
        |  v => v);
  fun eq (f1,f2) = (ord(f1,f2) = EQUAL);

  fun pretty (Terms (trms,fd)) = 
        Pretty.block
         [Pretty.str "|",Pretty.str fd,Pretty.str ":",
          Pretty.block (Pretty.commas (map (Syntax.pretty_term @{context}) trms)),
          Pretty.str "|"]
   |  pretty (Strings (ss,fd)) = Pretty.block
        [Pretty.str "|",Pretty.str fd,Pretty.str ":",StrName.NSet.pretty ss,Pretty.str "|"]
   |  pretty (StrCount (_,fd)) = Pretty.block [Pretty.str "StrCount: ", Pretty.str fd]
   |  pretty (Count (_,fd)) = Pretty.block [Pretty.str "Count: ", Pretty.str fd]
   |  pretty (Ref (s,fd)) = Pretty.block [Pretty.str "|",Pretty.str fd,Pretty.str ":", Pretty.str s,Pretty.str "|"]
   |  pretty (NoData fd) = Pretty.block [Pretty.str "NoData: ", Pretty.str fd];

end (* struct *)

structure F = NameFun(structure Namer = Feature val default_name = Feature.default_feature);


