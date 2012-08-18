(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *) 
(*  Title:      cinfos/descrip_cinfo.ML
    Author:     Lucas Dixon, University of Edinburgh
                lucasd@dai.ed.ac.uk
*)
(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *) 
(*  DESCRIPTION:

    Contextual Information for Reasoning state textual descriptions

*)
(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *)

signature DESCRIP_CINFO = 
sig
  structure I : INFO_ITEM where type T = RstName.T;
  exception descrip_cinfo_exp of string;

  val append_rst : RstName.T -> RState.T -> RState.T
  val append_techn : RstName.T -> RState.rtechn -> RState.rtechn
  val append_str_rst : string -> RState.T -> RState.T
  val append_str_techn : string -> RState.rtechn -> RState.rtechn
  val appblock_pretty_rst : Pretty.T -> RState.T -> RState.T
  val appblock_pretty_techn : Pretty.T -> RState.rtechn -> RState.rtechn
  val appchunk_pretty_rst : Pretty.T -> RState.T -> RState.T
  val appchunk_pretty_techn : Pretty.T -> RState.rtechn -> RState.rtechn

  val prepend_rst : RstName.T -> RState.T -> RState.T
  val prepend_techn : RstName.T -> RState.rtechn -> RState.rtechn
  val prepend_str_rst : string -> RState.T -> RState.T
  val prepend_str_techn : string -> RState.rtechn -> RState.rtechn
  val preblock_pretty_rst : Pretty.T -> RState.T -> RState.T
  val preblock_pretty_techn : Pretty.T -> RState.rtechn -> RState.rtechn
  val prechunk_pretty_rst : Pretty.T -> RState.T -> RState.T
  val prechunk_pretty_techn : Pretty.T -> RState.rtechn -> RState.rtechn

  val set_rst : RstName.T -> RState.T -> RState.T
  val set_techn : RstName.T -> RState.rtechn -> RState.rtechn
  val set_pretty_rst : Pretty.T -> RState.T -> RState.T
  val set_pretty_techn : Pretty.T -> RState.rtechn -> RState.rtechn
  val set_str_rst : string -> RState.T -> RState.T
  val set_str_techn :  string -> RState.rtechn -> RState.rtechn

  val pretty_rst : RState.T -> Pretty.T
  val string_of_rst : RState.T -> string

end;


(* Meta information for reasoning state descriptions *)
structure DescripCInfo : DESCRIP_CINFO= 
struct

  exception descrip_cinfo_exp of string;

  structure I = 
  InfoFUN( 
    struct
      type T = RstName.T;
      val name = "descrip";
(* (fn _ => raise descrip_cinfo_exp "initial unnamed reasoning state") *)
      val init = RstName.str "initial unnamed reasoning state";
      val pretty = I;
    end
  );

  fun pretty_rst rst = 
      RstName.apply (I.get_from_rst rst) rst;

  val string_of_rst = Pretty.string_of o pretty_rst

  fun appblock_pretty s d = RstName.append_block (RstName.pretty s) d;
  fun preblock_pretty s d = RstName.prepend_block (RstName.pretty s) d;
  fun appchunk_pretty s d = RstName.append_chunks (RstName.pretty s) d;
  fun prechunk_pretty s d = RstName.prepend_chunks (RstName.pretty s) d;

  (* implicit string, T, () *)
  val mk_from_str = RstName.str;
  val append_str = RstName.append_block o RstName.str;
  val prepend_str = RstName.prepend_block o RstName.str;

  (* implicit string and rst *)
  val set_rst = I.put_in_rst;
  val append_rst = I.update_rst o RstName.append_block;
  val prepend_rst = I.update_rst o RstName.prepend_block;

  val set_pretty_rst = I.put_in_rst o RstName.pretty;
  val appblock_pretty_rst = I.update_rst o appblock_pretty;
  val preblock_pretty_rst = I.update_rst o preblock_pretty;
  val appchunk_pretty_rst = I.update_rst o appchunk_pretty;
  val prechunk_pretty_rst = I.update_rst o prechunk_pretty;

  val set_str_rst = I.put_in_rst o mk_from_str;
  val append_str_rst = I.update_rst o append_str;
  val prepend_str_rst = I.update_rst o prepend_str;

  (* rtechn *)
  fun set_techn pf rtech = rtech
    |> RTechn.set_appf (Seq.map (set_rst pf) o (RTechn.get_appf rtech));
  fun append_techn pf rtech = rtech
    |> RTechn.set_appf (Seq.map (append_rst pf) o (RTechn.get_appf rtech));
  fun prepend_techn pf rtech =  rtech
    |> RTechn.set_appf (Seq.map (prepend_rst pf) o (RTechn.get_appf rtech));

  fun set_pretty_techn p rtech = rtech
    |> RTechn.set_appf (Seq.map (I.put_in_rst (RstName.pretty p)) o (RTechn.get_appf rtech));
  fun appblock_pretty_techn s rtech = rtech
    |> RTechn.set_appf (Seq.map (appblock_pretty_rst s) o (RTechn.get_appf rtech));
  fun preblock_pretty_techn s rtech = rtech
    |> RTechn.set_appf (Seq.map (preblock_pretty_rst s) o (RTechn.get_appf rtech));
  fun appchunk_pretty_techn s rtech = rtech
    |> RTechn.set_appf (Seq.map (appchunk_pretty_rst s) o (RTechn.get_appf rtech));
  fun prechunk_pretty_techn s rtech = rtech
    |> RTechn.set_appf (Seq.map (prechunk_pretty_rst s) o (RTechn.get_appf rtech));

  fun set_str_techn s rtech = rtech
    |> RTechn.set_appf (Seq.map (I.put_in_rst (mk_from_str s)) o (RTechn.get_appf rtech));
  fun append_str_techn s rtech =  rtech
    |> RTechn.set_appf (Seq.map (append_str_rst s) o (RTechn.get_appf rtech));
  fun prepend_str_techn s rtech =  rtech
    |> RTechn.set_appf (Seq.map (prepend_str_rst s) o (RTechn.get_appf rtech));

end;
