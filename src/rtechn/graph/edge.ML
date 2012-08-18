(********************************************)
(* EDGE *)
(********************************************)

structure EdgeOrdData : ORD_DATA =
struct
  type data = StrIntName.name  (* WireNode.T *)
  val pretty_data = StrIntName.pretty_name;
  val print_data = Pretty.writeln o pretty_data;

  fun ord dest_wire src_wire = 
    let 
        val src_toks =  String.tokens (fn s => s = #".") src_wire 
        val dest_toks = String.tokens (fn s => s = #".") dest_wire
        fun chk_tok t1 t2 = (t1 = t2)
        fun match (st::sts) (dt::dts) = chk_tok st dt andalso match sts dts 
          | match _ [] = true
          | match _ _ = false
    in 
       match src_toks dest_toks 
    end;

  fun data_ord ((w1,_),(w2,_)) = 
     if w1 = w2 then EQUAL (* strings are equal *)
     else case ord w1 w2 of
        true => LESS (* w1 is a substreing of w2 *)
      | false => GREATER;

 (* fixme: not sure how this is actually used: we may need to take into account the second
    arg (integer) too here, but then data_ord(e1,e1) = EQUAL /= data_eq(e1,e2) *)
 fun data_eq (e1,e2) = (data_ord(e1,e2) = EQUAL);
end (* struct EdgeData *)

structure EData = 
   IgnoredUnifiableData(
      structure D = EdgeOrdData 
      structure S = RTData
      val default_data = ("goal",0));

structure EComponentData_Param : ELEMENT_COMPONENT_DATA_PARAM where type data = EData.data =
struct
    type data = EData.data;
    exception unknown_type_exp of string;
    fun type_of _ = "";
    fun cdata_of _ = ComponentData.Unit;
    fun default_data n = raise unknown_type_exp n;
    fun update _ = I;
end; (* struct EComponentData_Param *)

structure EComponentData = ElementComponentData(EComponentData_Param);

