
   
signature PROVER= 
sig

 type typ 
  type term
  type thm 
  type context

  type pplan
  type pnode
  type appf
  type tactic 

  val match :  context -> (term * term) -> bool  (*TODO : context -> (term * term) -> bool *)
  (* val concl_of_thm *)  (* TODO: thm -> term *)
  (* val asms_of_thm *)  (*: TODO:  thm -> term list ? *)
(* 
  val apply_tactic : tactic -> appf *)
  val get_open_pnodes : pplan -> pnode list
  val get_pnode_name : pnode -> string
  val get_pnode_concl : pnode -> term (* return type concl which would be type term*)
  val get_pnode_hyps : pnode -> term list
  val get_pnode_ctxt : pnode -> context


end

structure RodinProver  : PROVER = 
struct
 
  type typ = string
  type term = string
  type thm = string
  type context = string

  type tactic = string

  type pplan = string (* dummy *)
  type pnode = string

  type appf = pnode * pplan -> (pnode list * pplan) Seq.seq  

  fun match context  (ta ,tb) = true    (*TODO : context -> (term * term) -> bool *)
  fun concl_of_thm  thm ="term" (* TODO: thm -> term *)
  fun asms_of_thm  thm = ["term","list"] (*: TODO:  thm -> term list ? *)

  fun map_tactic name = case name of 
      ""=>""
    | "a"=>"b"
    | "c"=>"d"
(* 
  fun apply_tactic pn pplanstr =  [([""], "")]  *)
(*     fun name_open_pnodes pnodes 	=	
  let val num =(get_open_pnodes_num)+1;
       val pn= (List.length  pnodes)+1;
       val cmd=Rodin.toRodin instance ("",[]);
       val cmd=Rodin.toRodin instance ("NAME_OPEN_NODES", nameAfter num pn) |> Rodin.fromRodin;
  in
      Rodin.getParamValues cmd
  end; *)
 
  fun get_open_pnodes_num _  =
  let
      val cmd=(Rodin.toRodin ("GET_OPEN_DESCENDANTS_NUM",[]))  |> Rodin.fromRodin ;
      val num=Rodin.getParam cmd "NUM"
 in
       Option.getOpt (Int.fromString num, 0)
 end;
 fun toInt str= Option.getOpt (Int.fromString str, 0)

 fun nameAfter i pn = if pn>0 then
 (Int.toString i,"G"^(Int.toString pn)) :: nameAfter (i+1) (pn-1) 
 else []

 
 
 fun get_open_pnodes pplan = 
 let
     val ins = (Rodin.toRodin  ("GET_ALL_OPEN_NODES",[("PPLAN",pplan)]));
     val cmd=Rodin.fromRodin ins;
     val next = case Rodin.getCmdName cmd of
              "NEED_NAMING" =>  
                   let val num=toInt(Rodin.getParam cmd "NUM")
                       val ins =(Rodin.toRodin ("NAME_OPEN_NODES", nameAfter 1 num ))
                   in
                    Rodin.fromRodin ins
                   end
              | "NAMES" => cmd
              | _ => raise error "Wrong command"
     val nodes = Rodin.getParamValues next
  in  
      nodes  
  end;

 val get_pnode_name = I

  fun get_pnode_concl pn =	"conclude"  (* return type concl which would be type term*)

  fun get_pnode_hyps  pn  =	["hyps"] (*Dummy *)

  val get_pnode_ctxt = I
 
end
