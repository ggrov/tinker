(* POSSIBLE QUERY
INST 2 WHICH MATCH XX BETWEEN X AND X
COUNTER WHICH MATCH XX BEFORE X OR AFTER X
EQ_REWRITE WHICH MATCH GOALSYMB AFTER X

syntax is

Tactic WHICH ([not] cond) [and|or [not] conds])

 *)

signature HYPQUERY_PARSER =
sig
  datatype token =
                  (* the Root query, only used for AST *)
                  QUERY
                  
                  (* the condition clause *)
                  |WHICH 

                  (* Predicative token *)
                  |HAS | MATCH | IS 

                   (* Propositional token *)
                  | BEFORE | BETWEEN | AFTER | IN | AS | FIRST | LAST | WITH

                  (* Logic token *)
                  | OR | AND | NOT
                  
                  (* Tactic token *)
                  | INST | CT | CASE_SPLIT | MODUS_PONENS | MODUS_TOLLENS | EQ_REWRITE

                  (* Other key words *)
                  | LBRA | RBRA | COMMA | GOALSYMB | TOPSYMB | STR of string

  type TAG
  datatype AST = node of TAG * AST list
  val parse : string -> AST
  val pretty : AST -> unit
  val tokenToLex : token -> string
end

structure hypQueryParser: HYPQUERY_PARSER =
struct
  (* Key word and AST token *)
  datatype token =
                  (* the Root query, only used for AST *)
                  QUERY
                  
                  (* the condition clause *)
                  |WHICH 

                  (* Predicative token *)
                  |HAS | MATCH | IS 

                   (* Propositional token *)
                  | BEFORE | BETWEEN | AFTER | IN | AS | FIRST | LAST | WITH

                  (* Logic token *)
                  | OR | AND | NOT
                  
                  (* Tactic token *)
                  | INST | CT | CASE_SPLIT | MODUS_PONENS | MODUS_TOLLENS | EQ_REWRITE

                  (* Other key words *)
                  | LBRA | RBRA | COMMA | GOALSYMB | TOPSYMB | STR of string

  type tokens = token list

  (* AST tag, just use the token *)
  type TAG=token
  datatype AST = node of TAG * AST list
  

  fun tokenise stack [] = [String.implode stack]
    | tokenise stack (chr :: xs) = 
      let fun filterBlank s = case s of "" => false | _ => true
          val r=
              if (Char.isSpace chr) then 
                if stack=[]  then  
                  (tokenise [] xs) 
                else  
                  (String.implode stack) :: (tokenise [] xs)
              else if (chr = #",") then
                 (String.implode stack) ::(",") :: (tokenise [] xs)
              else if (chr = #"(") then
                 (String.implode stack) ::("(") :: (tokenise [] xs)
              else if (chr = #")") then
                 (String.implode stack) ::(")") :: (tokenise [] xs)
              else
                (tokenise (stack @ [chr]) xs)
     in 
        List.filter filterBlank r
     end

  fun tokenToLex token = case token of 
  QUERY=> "QUERY" 
  |WHICH => "WHICH"

  (* Predicative token *)
  |HAS =>"HAS"| MATCH=>"MATCH" | IS=>"IS" 
  
  (* Propositional token *)
  | BEFORE=>"BEFORE" | BETWEEN=>"BETWEEN" | AFTER=>"AFTER" | IN=>"IN" | AS=>"AS" | WITH=>"WITH"
  | FIRST =>"FIRST" | LAST=>"LAST"
  
  (* Logic token *)
  | OR=>"OR" | AND=>"AND" | NOT=>"NOT"
                    
  (* Tactic token *)
  | INST=>"INST" | CT=>"CT"
  | CASE_SPLIT=>"CASE_SPLIT"
  | MODUS_PONENS=>"MODUS_PONENS"
  | MODUS_TOLLENS=>"MODUS_TOLLENS" 
  | EQ_REWRITE=>"EQ_REWRITE"
  
  (* Other key words *)
  | TOPSYMB => "TOPSYMB"
  | GOALSYMB=>"GOALSYMB"
  | COMMA=>","
  | LBRA=>"("
  | RBRA=>")"

  (* other string symbol  *)
  | STR str =>  str

   fun lexToToken lex = case lex of 
   "WHICH" => WHICH

  (* Predicative token *)
  | "HAS"=>HAS | "MATCH"=>MATCH | "IS"=>IS 
  
  (* Propositional token *)
  | "BEFORE"=>BEFORE | "BETWEEN"=>BETWEEN | "AFTER"=>AFTER | "IN"=>IN | "AS"=>AS  | "WITH"=>WITH
  
  (* Logic token *)
  | "OR"=>OR | "AND"=>AND | "NOT"=>NOT
                    
  (* Tactic token *)
  | "INST"=>INST | "CT"=>CT 
  | "CASE_SPLIT"=>CASE_SPLIT 
  | "MODUS_PONENS"=>MODUS_PONENS
  | "MODUS_TOLLENS"=>MODUS_TOLLENS 
  | "EQ_REWRITE"=>EQ_REWRITE
  
  (* Other key words *)
  | "TOPSYMB"=>TOPSYMB
  | "GOALSYMB"=>GOALSYMB 
  |  ","=>COMMA
  |  "("=>LBRA
  |  ")"=>RBRA
  (* other string symbol  *)
  | str =>  STR str

  fun isTacticToken token = case token of
  INST=>true | CT=>true | CASE_SPLIT=>true | MODUS_PONENS=>true | MODUS_TOLLENS=>true | EQ_REWRITE=>true | _ =>false
  
  fun isTacticWithParam token = case token of
  INST => true
  | _=>false



  fun yytext token expection = 
  
   case expection of 
    STR _ => 
      let 
      in 
        (case token of 
              STR _ => SOME token
                | _ => NONE)
      end
   | tk => if tk=token then SOME tk else (NONE)

(* 
  fun yytext2 token expections = 
    let val result=( map (yytext token) expections |> filter (fn NONE=>false | _=>true))
      in
        case result of [] => NONE | r => List.hd r
      end *)

  fun parsingError token expection =  raise error ("Expected token: ("^(tokenToLex expection)^ "), but found : ("^(tokenToLex token)^")")
  fun parsingError2 token expections = 
    raise error ("Expected token: ("^ 
      (map (tokenToLex) expections
        |> (fn (x::[])=>[x] | (x::xs)=> x::","::xs | [] => raise error "Expections is Null") 
        |> String.concat)
    ^ "), but found : ("^(tokenToLex token)^")")

(* Condition terms *)
  fun parseCondTerm (token::xs)=
      (case token of 
        GOALSYMB => (token, xs)
       | STR s=> (STR s, xs)
       | _=> parsingError2 token [WHICH, STR "Term String"] 
      )
    | parseCondTerm []= raise error "Unexpected end parseCondTerm"

  fun parseProp [] = ([],[])
    | parseProp (_::[]) = raise error "Unexpected end parseProp" 
    | parseProp (token::xs) = 
      if token = BEFORE orelse token=AFTER then
        let val (symb1, remain)=parseCondTerm xs
        in
           ([node (token, [ node (symb1, [])])],remain)
        end
      else if token=BETWEEN then
        (* Between A AND B *)
        let val (a, remain1) =parseCondTerm xs
            val next= if remain1=[] then raise error "Unexpected end parseProp" else List.hd remain1
            val (b, remain2) = case next of AND => parseCondTerm (List.tl remain1) | _=> parsingError next AND
        in
           ([node (token, [
                             node (a,[]),
                             node (b,[]) 
                          ]
                     )
             ],
             remain2)
        end
      else
        raise error "Unexpected symbol" (* Should never happen *)
         

  fun parseMH (token::xs)=
    let val (term1, remain) = parseCondTerm xs
        val next = case remain of [] => [] | _ => ([List.hd remain])
    in 
        if remain=[] orelse (next=[BETWEEN] orelse next=[BEFORE] orelse next=[AFTER])=false then
          (node (token, [node (term1,[])]),remain)
        else
          let val (prop, remain2) = parseProp remain in
          (node (token, [node (term1,[])] @ prop ),remain2)
          end
    end
  | parseMH [] = raise error "Unexpected end. parseMH"

  fun parseIS (token::xs)=
  let val (term1, remain)=parseCondTerm xs
  in
    (node (token, [node (term1, [])]),remain)
  end
  |  parseIS [] = raise error "Unexpected end. parseIS"

  fun parseWITH (token::xs)=
  (case token of TOPSYMB =>
  let val (term1, remain)= parseCondTerm xs
  in
    (node (WITH, [
                   node (TOPSYMB, [
                                    node (term1, [])
                                  ])
                  ])
    ,remain)
  end
  | _=> parsingError token TOPSYMB
  )
  |  parseWITH [] = raise error "Unexpected end. parseWITH"

  fun parseCondition (token::xs)  = 
    (case token of 
      WITH => parseWITH (xs)
    | MATCH=> parseMH  (token::xs) 
    | HAS=> parseMH  (token::xs) 
    | IS => ((* writeln ("parsing IS"); *)parseIS (token::xs))
    | _ => parsingError2 token [MATCH, IS] )
  | parseCondition [] = raise error "Unexpected End. parseCondition"


  fun  parseBracket (token::xs) parseOR parseAND is_and =
  ((* writeln ("parseBRA token="^(tokenToLex token)); *)
    case token of  LBRA =>
    let val (n, remain)= parseOR xs 
        val t= case remain of [] => raise error "Unexpected end. parseBracket" | _ => yytext (List.hd remain) RBRA
        val _=case t of NONE => parsingError ((List.hd remain)) RBRA | _=>()
        val (_::next) = remain
    in
         (n, next)
    end
 | NOT =>
    let val (n, remain)= parseOR xs in
      (node (NOT,[n]), remain)
    end
 | _ => if is_and then parseAND (token::xs) parseOR else parseCondition (token::xs))
 | parseBracket [] _ _ _ = raise error "Unexpected end. parseBracket"

 fun parseAND (token::xs) parseOR =
  let(*  val _ = writeln ("parseAND token="^(tokenToLex token)) *)
      val (c1,remain) = parseBracket (token::xs) parseOR parseAND false
  in
    if not(remain=[]) then
      let val next_token= List.hd remain 
      in
        if (next_token = AND) then
          let val (c2,newremain)=parseAND  (List.tl remain) parseOR
          in
            (node (next_token, c1::[c2]),newremain)
          end
        else
         (*  (writeln "NOT AND"; *)
          (c1, remain)
      end
    else
      (c1, remain)
  end

  | parseAND [] _  = raise error "Unexpected end. parseAND"

  fun parseOR (token::xs) = 
        let
           (*  val _ = writeln ("parseOR token="^(tokenToLex token)) *)
             val (c1,remain) =(* case token of LBRA=> parseBracket (token::xs) parseOR parseAND true |_=> *) parseAND (token::xs) parseOR
        in
          if not(remain=[]) then
            let val next_token= List.hd remain 
            in
              if (next_token = OR) then
                let val (c2,newremain)=parseOR (List.tl remain)
                in
                  (node (next_token, c1::[c2]),newremain)
                end
              else 
                (c1, remain)
             end
           else
         (c1, remain)
       end
  | parseOR [] = raise error "Unexpected end."

(* 
  fun getTag (node (tag, _)) =tag

 *)

  fun parseConditionClause (token::xs) = 
    let val t= yytext token WHICH
         val _ = case t of NONE => parsingError token WHICH | _=>()
    in
      parseOR xs
    end
    (* If there is no conditional clause / which does not appear after tactic
       Directly select the first hyp
       This may cause problems as the hypotheiss may not be available to the tactic
       therefore not recommended. User mush be very clear of what they are doing
    *)
  | parseConditionClause [] = (node (IS,[node (FIRST,[])]), [])

  fun   parseParams [] = 
    raise error ("Expected some Param ")
        |parseParams (token::xs) = 
  let(*  val _=writeln (tokenToLex token) *)
      val temp=yytext token (STR "Some param")
      val t= if temp=SOME token then token else parsingError token (STR "Some param")
      val temp2=List.hd xs
      val t2=yytext (temp2) COMMA
  in
    case t2 of 
    SOME COMMA =>
      let 
          val cur_param_node=node (t,[])
          val (next_param_node, remain)=  parseParams (List.tl xs) 
      in
          ( cur_param_node :: next_param_node, remain)
      end
    | SOME _=>
      ([node (t,[])],xs) 
    | NONE =>
      ([node (t,[])],xs) 
  end

  fun parseTactic (token::xs) = 
    
      if isTacticToken token then
        if isTacticWithParam token then
          let val (params_node,remain) = parseParams xs
          in
              (node (token, params_node), remain)
          end
        else 
          (node (token,[]),xs)
      else 
        raise error ("Expected tactic keyword. ")
     | parseTactic [] = raise error "Parsing Tactic, unexpected end."

  fun parse input = 
    let val chars=String.explode input
        val words=tokenise [] chars
        val tokens= map lexToToken words
        val (tac, remain) = parseTactic tokens
    in
          let val (clause, remain2)=parseConditionClause remain 
               val _= case not(remain2=[]) of true => raise error "Parsing error, unexpected token" | _=>() 
          in
            node (QUERY,[tac, clause])
          end
    end;

  fun whitespace i = if i>2 then " "^ (whitespace (i-1)) else 
                     if i=2 then "|"^ (whitespace (i-1)) else
                     if i=1 then "-"^ (whitespace (i-1)) else
                     ""
                     

  fun pretty0 depth (node (token, children)) = 
    ( writeln ((whitespace depth)^(tokenToLex token));
      map (pretty0 (depth+4)) children;
      ()
    )
   
  fun pretty ast = pretty0 0 ast

  

end
(* 
open hypQuery;

type condition = {params: string list, handler : string list -> bool}


val test= yytext WHICH COMMA
datatype 'a tree = Empty | Node of 'a *  'a tree list

val TEST2=(COMMA=WHICH)

val a=tokenise [] (String.explode s);
val p= (map lexToToken a);
val zz=yytext (STR "som") WHICH

val kk=pretty k *)


val s= "INST 1 WHICH MATCH a AFTER b"
val k= hypQueryParser.parse s
val kk=hypQueryParser.pretty k 
(* HypQuery third party interface signature *)
signature hypQueryTPInterface = 
sig
  type hyp = string
  type symbol = string
  type pnode

  val get_hyps : pnode-> hyp list
  val get_top_symbol : hyp-> pnode -> string
  val get_symbols : hyp-> pnode -> symbol list
end

signature HYPQUERY =
sig                          
  structure parser : HYPQUERY_PARSER
  structure interface : hypQueryTPInterface
  type AST= parser.AST
  type pnode=string
  val parse : string -> AST 
  
  val evalQuery : AST -> pnode -> (string * string * string)

end

