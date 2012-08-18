(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *) 
(*  Title:      core/inftools.ML
    Author:     Lucas Dixon, University of Edinburgh
                lucasd@dai.ed.ac.uk
*)
(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *) 
(*  DESCRIPTION:

  Making specific kinds of contextual info 

*)
(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *)

(* the minimal specification for a kind of information held in the
table of contextual information. Note that the name must be unique,
otherwise when we try to add it to the contextual information and
exception will be thrown.  *)




signature INFO_KIND = 
sig
  val name : string
  type T
  val init : T
  val pretty : T -> RState.T -> Pretty.T
end;

(* for local info, no init function as it starts off by not having an entry *)
signature LOCAL_INFO_KIND = 
sig
  val name : string
  type T
  val pretty : T -> RState.T -> Pretty.T
end;



(* the interface for working with kinds of contextual information, ie
this is the output of teh functor, given input of the INFO_KIND
strutcure. *)
signature INFO_ITEM = 
sig
  type T

  (* initial value *)
  val init : T
  (* set initial value in context *)
  val init_in_thy : Context.theory -> Context.theory
  val init_in_ctxt : Proof.context -> Proof.context

  val get_from_cinfo : CInfo.T -> T
  val put_in_cinfo : T -> CInfo.T -> CInfo.T
  val update_cinfo : (T -> T) -> CInfo.T -> CInfo.T

  val get_from_rst : RState.T -> T
  val put_in_rst : T -> RState.T -> RState.T
  val update_rst : (T -> T) -> RState.T -> RState.T

  (* pretty *)
  val pretty : T -> RState.T -> Pretty.T
  val pretty_cinfo : CInfo.T -> RState.T -> Pretty.T
  val pretty_rst : RState.T -> Pretty.T

  val print : T -> RState.T -> unit
  val print_cinfo : CInfo.T -> RState.T -> unit
  val print_rst : RState.T -> unit

end;

(* contextual information functor, for making a structure that
interacts with contextual finromation for a specific data type *)
functor InfoFUN(InfoKind : INFO_KIND) : INFO_ITEM = 
struct 
  type T = InfoKind.T;

  val init = InfoKind.init;

  structure Entry = PolymEntryFun(InfoKind);
  
  (* initialise this kind of data into the theory thy. *)
  val init_in_thy = CInfo.Thy.map (Entry.set InfoKind.init);
  val init_in_ctxt = CInfo.Ctxt.map (Entry.set InfoKind.init);
  
  (* basic contextual information manipulations *)
  val get_from_cinfo = Entry.get;
  val put_in_cinfo = Entry.set;
  val update_cinfo = Entry.update;
  
  (* for working directly with rstates *)
  val get_from_rst = get_from_cinfo o RState.get_cinfo;
  val put_in_rst = RState.update_cinfo o put_in_cinfo;
  val update_rst = RState.update_cinfo o update_cinfo;
  
  (* pretty printing *)
  val pretty = InfoKind.pretty;
  val pretty_cinfo = pretty o get_from_cinfo;
  fun pretty_rst rst = pretty (get_from_rst rst) rst;
  
  val print = Pretty.writeln oo pretty;
  val print_cinfo = Pretty.writeln oo pretty_cinfo;
  val print_rst = Pretty.writeln o pretty_rst;

end;



(* the interface for working with local kinds of contextual
information, ie this is the output of the functor, given input of the
LOCAL_INFO_KIND strutcure. But this associates information to a specific
goal. I.e. cinfo which is indexed also by goalname. *)
signature LOCAL_INFO_ITEM = 
sig
  type T

  exception no_such_goal_exp of string;

  (* set initial value to NONE *)
  val init_in_thy : Context.theory -> Context.theory
  val init_in_ctxt : Proof.context -> Proof.context

  (* note rstate is the context in which to print *)
  val pretty :  T -> RState.T -> Pretty.T
  val pretty_cinfo : CInfo.T -> PPlan.gname -> RState.T -> Pretty.T
  val pretty_rst : RState.T -> PPlan.gname -> Pretty.T
  val pretty_all : RState.T -> Pretty.T
  
  val print : T -> RState.T -> unit
  val print_rst : RState.T -> PPlan.gname -> unit
  val print_cinfo : CInfo.T -> PPlan.gname -> RState.T -> unit
  val print_all : RState.T -> unit

  val get_from_cinfo : CInfo.T -> PPlan.gname -> T option
  val put_in_cinfo : (PPlan.gname * T) -> CInfo.T -> CInfo.T
  val update_cinfo : PPlan.gname -> (T -> T) -> CInfo.T -> CInfo.T

  val get : RState.T -> PPlan.gname -> T
  val get_opt : RState.T -> PPlan.gname -> T option
  val get_all : RState.T -> (PPlan.gname * T) list
  val put : (PPlan.gname * T) -> RState.T -> RState.T
  val update : PPlan.gname -> (T -> T) -> RState.T -> RState.T
end;


functor LocalInfoFUN(InfoKind :  LOCAL_INFO_KIND ) 
 : LOCAL_INFO_ITEM
= struct 
  (*val kind = SafeObject.kind InfoKind.name;*)
  val kind = SafeObject.kind "Local Info";
  
  (* type of an entry of this kind for a given goal *)
  type T = InfoKind.T;
  
  (* exception for wrong goal lookup *)
  exception no_such_goal_exp of string;
  
  (* init function for cinfo *)
  val init = GoalTab.empty;
  
  (* pretty in the context of a reasoning state *)
  val pretty = InfoKind.pretty;
  
  (* the CInfo entry *)
  structure I = InfoFUN(
      struct
        type T = InfoKind.T GoalTab.table;
  
        (* prefix all kinds with "local:" *)
        val name = "local:" ^ InfoKind.name;
  
        (* init is the table init *)
        val init = init;
  
        (* pretty print each element *)
        val pretty = (fn d => fn rst => 
          Pretty.chunks 
            (map (fn (gname,v) => 
                     Pretty.block 
                       [Prf.pretty_gname gname,
                        Pretty.str " => ",
                        InfoKind.pretty v rst])
                 (GoalTab.dest d))); (* print all things *)
      end);
  
  (* setup function is then just the cinfo setup function *)
  val init_in_thy = I.init_in_thy;
  val init_in_ctxt = I.init_in_ctxt;
  
  (* implicit cinfo *)
  val get_localtable_from_cinfo = I.get_from_cinfo;
  
  (* NOTE: these don't update the local cinfo table *)
  (* basic contextual information manipulations. *)
  val get_from_cinfo = GoalTab.lookup o get_localtable_from_cinfo;
  val put_in_cinfo = I.update_cinfo o GoalTab.update;
  val update_cinfo = I.update_cinfo oo GoalTab.map_entry;
  
  (* for working directly with rstates *)
  (* implicit rstate gname *)
  val get_opt = get_from_cinfo o RState.get_cinfo
  fun get rst gname = 
      case (get_opt rst gname)
       of NONE => raise no_such_goal_exp ("No contextual info for goal: " ^ gname)
        | (SOME rcinfo) => rcinfo;
  
  (* implicit rst *)
  val get_all = GoalTab.dest o I.get_from_rst;
  fun put (gname, data) = 
      (RState.update_lcinfo 
         (LCInfo.add (InfoKind.name, (fn g => put_in_cinfo (g, data))) gname) 
       handle Match => raise ERROR "in left hand side")
      o ((RState.update_cinfo
           (put_in_cinfo (gname, data)))
         handle Match => raise ERROR "in right hand side")
  
  (* using put to make sure that the lcinfo get's updated also *)
  fun update gname f rst = put (gname, f (get rst gname)) rst;
  
  (* more pretty printing *)
  fun pretty_cinfo (cinfo : CInfo.T) (g : Prf.gname) (rst : RState.T) = 
      case get_from_cinfo cinfo g 
       of NONE => Pretty.str "NONE"
        | SOME x => pretty x rst;
  fun pretty_rst rst g = pretty_cinfo (RState.get_cinfo rst) g rst;
  fun pretty_all rst = I.pretty (I.get_from_rst rst) rst;
  
  val print = Pretty.writeln oo pretty;
  fun print_cinfo c = Pretty.writeln oo (pretty_cinfo c);
  val print_rst = Pretty.writeln oo pretty_rst;
  val print_all = Pretty.writeln o pretty_all;

end;
