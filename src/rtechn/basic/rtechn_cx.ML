
structure WireKey : NAME where type name = string = StrName;
structure GNodeKey : NAME where type name = string * int = StrIntName;

structure RTechnTab = Table(type key = RTechnKey.name val ord = RTechnKey.name_ord);
structure WireTab = Table(type key = WireKey.name val ord = WireKey.name_ord);
structure GNodeTab = Table(type key = GNodeKey.name val ord = GNodeKey.name_ord);

structure RTechn_Ctxt =
struct 
  exception undefined_exp of RTechnKey.name

  structure Ctxt = Theory_Data(struct 
    type T = RTechn.T RTechnTab.table
    val empty = RTechnTab.empty;
    val extend = I;
    val merge = RTechnTab.merge RTechn.eq
  end);

  val add_el = RTechnTab.update;
  val delete_el = RTechnTab.delete_safe;
  fun get_el key tab = case RTechnTab.lookup tab key of
                        NONE => raise undefined_exp key
                      | SOME v => v;

  structure Theory =
  struct
    val all_rtechns = Ctxt.get;
    fun get_rtechn th key = get_el key (Ctxt.get th);
    fun delete_key key = Ctxt.map (delete_el key);
    fun delete_rtechn rt = Ctxt.map (delete_el (RTechn.get_name rt));
    fun add_rtechn rt = Ctxt.map (add_el (RTechn.get_name rt,rt));
    fun contains_name th name  = RTechnTab.defined (Ctxt.get th) name;
    fun fresh_name th name = 
      Ctxt.get th 
      |> RTechnTab.keys
      |> RTechnKey.NSet.of_list
      |> (fn ns =>  RTechnKey.NSet.new ns name);

  end; (* struct *)

  structure RState =
  struct
    (* (theory -> theory) -> Proof.context -> Proof.context *)
    val map_th_ctxt = Context.proof_map o Context.map_theory;
    val th_of_rst = Proof_Context.theory_of o RState.get_ctxt

    val all_rtechns = Theory.all_rtechns o th_of_rst;
    fun get_rtechn rst key = Theory.get_rtechn (th_of_rst rst) key;
    fun delete_key key = map_th_ctxt (Theory.delete_key key);
    fun delete_rtechn rt = RState.update_ctxt (map_th_ctxt (Theory.delete_rtechn rt));
    fun add_rtechn rt = RState.update_ctxt (map_th_ctxt (Theory.add_rtechn rt));
    fun contains_name rst key = Theory.contains_name (th_of_rst rst) key;
    fun fresh_name rst key = Theory.fresh_name (th_of_rst rst) key;
  end;

end;

(* Keep wires in the context: for easier integration with the graphical interface 

  wire key : (wirename,int) -> matching only on wirename...
  goal key : (goalname,int)

    datatype data = GoalNode of (string * int) -- wire identifier 
                              * SStrName.NSet.T --
                | RTechnNode of string; -- technique name

*)

structure FWire_Ctxt =
struct

  exception undefined_exp of WireKey.name

  structure Ctxt = Theory_Data(struct 
    type T = WireNode.T WireTab.table
    val empty = WireTab.empty;
    val extend = I;
    val merge = WireTab.merge WireNode.WInfo.eq;
  end);

  fun of_str str = str;

  val add_el = WireTab.update;
  val delete_el = WireTab.delete_safe;
  fun get_el key tab = case WireTab.lookup tab key of
                        NONE => raise undefined_exp key
                      | SOME v => v;

  structure Theory =
  struct
    val all_wires = Ctxt.get;
    fun get_wire th key = get_el key (Ctxt.get th);
    fun delete_key key = Ctxt.map (delete_el key);
    fun add_wire (wname,wire) = Ctxt.map (add_el (wname,wire));
    fun contains_name th name = WireTab.defined (Ctxt.get th) name;
    fun fresh_name th name = 
      Ctxt.get th 
      |> WireTab.keys
      |> WireKey.NSet.of_list
      |> (fn ns =>  WireKey.NSet.new ns name);

  end; (* struct *)

  structure RState =
  struct
    (* (theory -> theory) -> Proof.context -> Proof.context *)
    val map_th_ctxt = Context.proof_map o Context.map_theory;
    val th_of_rst = Proof_Context.theory_of o RState.get_ctxt

    val all_wires = Theory.all_wires o th_of_rst;
    fun get_wire rst key = Theory.get_wire (th_of_rst rst) key;
    fun delete_key key = RState.update_ctxt (map_th_ctxt (Theory.delete_key key));
    fun add_wire (wname,wire) = RState.update_ctxt (map_th_ctxt (Theory.add_wire (wname,wire)));
    fun contains_name rst key = Theory.contains_name (th_of_rst rst) key;
    fun fresh_name rst key = Theory.fresh_name (th_of_rst rst) key;
  end;

end (* struct *)

structure GNode_Ctxt =
struct
   exception notincontext_exp

  (* uses Proof data instead since this should only be there during a proof! *)
   structure Ctxt = Proof_Data(struct type T = GNode.goal GNodeTab.table fun init _ = GNodeTab.empty end);

  fun of_str str = (str,0);

   val add_el = GNodeTab.update ;
   val delete_el = GNodeTab.delete_safe
   fun get_el g tab = case GNodeTab.lookup tab g of
                        NONE => raise notincontext_exp
                      | SOME v => v

  
    fun get g rst = get_el g (Ctxt.get (RState.get_ctxt rst));
    val add = RState.update_ctxt o Ctxt.map o add_el;
    val delete = RState.update_ctxt o Ctxt.map o delete_el;

    fun contains_name rst name = GNodeTab.defined (Ctxt.get (RState.get_ctxt rst)) name;
    fun fresh_name rst name = 
      Ctxt.get (RState.get_ctxt rst) 
      |> GNodeTab.keys
      |> GNodeKey.NSet.of_list
      |> (fn ns => GNodeKey.NSet.new ns name);

   structure Wire =
   struct
     structure Ctxt = Proof_Data(struct type T = BWire.name WireTab.table fun init _ = WireTab.empty end);
     exception wire_notincontext_exp of string * (BWire.name WireTab.table)
     val of_str = I; 
     val add_el = WireTab.update ;
     val delete_el = WireTab.delete_safe
     fun get_el g tab = case WireTab.lookup tab g of
                          NONE => raise wire_notincontext_exp (g,tab)
                        | SOME v => v
     fun get g rst = get_el g (Ctxt.get (RState.get_ctxt rst));
     val add = RState.update_ctxt o Ctxt.map o add_el;
     val delete = RState.update_ctxt o Ctxt.map o delete_el;

    fun contains_name rst name = WireTab.defined (Ctxt.get (RState.get_ctxt rst)) name;
    fun fresh_name rst name = 
      Ctxt.get (RState.get_ctxt rst) 
      |> WireTab.keys
      |> WireKey.NSet.of_list
      |> (fn ns => WireKey.NSet.new ns name);
   end; (* struct Wire *)

end (* struct *)

(*
  structure RTName : SSTR_NAME = struct open SStrName; val default_name = mk "RTa"; end; 
  structure RTab = NameTabFun(RTName); *)

