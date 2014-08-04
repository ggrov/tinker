structure Clause_GT =
struct
 
 (* the types *)
 (* what about built-in - e.g. concl and hyps? *)
 datatype Args = Name of string 
                | Concl
                | Hyps
                | Term of string (* fix me: should we make this term? *)
                | Clause of string * (Args list)
 datatype Prog = Def of Args * Args list
               | Constraint of Args;
 type Program = Prog list;  

 (* TO DO: write type checker *)
 (*
   atomics : should be registered in psgraph
 *)
 (* these will be prover specific! but language using them should be generic *)       
 type atom = Arg list -> env -> env list (* empty is failure *)

 (*
   f(X,Y) :- a(X,Y), b(X,Y).
   f(g(X),Y) :- b(X),c(Y).
   f(g(test),h(test2)).
 *)

 (* scan of letters and identifiers *)
 val valid_id_symbols = ["_"]
 fun valid_letter x = Symbol.is_ascii_identifier x  orelse member (op =) valid_id_symbols x ;
 val scan_letter = Scan.one valid_letter;
 val scan_id  = (scan_letter || $$ "?") -- ((Scan.repeat scan_letter) >> implode) >> op ^ ;
 val scan_name  = (scan_letter) -- ((Scan.repeat scan_letter) >> implode) >> op ^ ;

 (* turn string into list of singleton strings - throw away whitespace etc  *)
 val filter_pred' = member (op =) [" ","\n","\t"];
 val filter_pred = not o filter_pred'; 
 val filter_symbs = filter filter_pred;
 val explode = Symbol.explode #> filter_symbs;

 (* some generic rules (did not work though so not used below *)
 val scan_empty  = $$ "("  -- $$ ")" >> K ([]:Args list);
 fun gen_scan_list sep f =  f -- Scan.repeat ($$ sep |-- f)  >> op ::;
 val gen_scan_comma_list = gen_scan_list "," ;
 fun gen_scan_para f = $$ "("  |--  gen_scan_comma_list f --| $$ ")" ;
 (* type restricted *)
 fun gen_scan_para_args (f:string list -> Args * string list) = gen_scan_para_args f;

 (* scan clause *)
 val scan_term = $$ "\"" |--  Scan.many (fn s => not(s = "\"")) --| $$ "\"" >> implode >> Term;  
 fun scan_clause xs  =  (scan_name -- (scan_args || scan_empty) >> Clause) xs 
 (* Note does not turn into term *)
 (* note: terms not supported*)
 and scan_arg xs = (scan_clause || scan_id >> Name || scan_term) xs
 and scan_args xs = (* gen_scan_para_args scan_arg xs *)
  ($$ "("  |--  scan_arg -- Scan.repeat ($$ "," |-- scan_arg) --| $$ ")" >> op :: ) xs; 

 (* body *)
 val scan_body = 
   scan_clause -- Scan.repeat ($$ "," |-- scan_clause) --| $$ "." >> op :: ; 
 val scan_prog = (* note: should not allow general arguments *)
    (scan_clause --| ($$ ":" -- $$ "-") -- scan_body >> Def)
    ||
    (scan_clause --| $$ "." >> Constraint);
  fun scan_all f [] = []
   |  scan_all f xs = 
       let 
          val (result,str) = f xs
       in
          result :: scan_all f str
       end;
  val scan_program = explode #> scan_all scan_prog; 

(*
  evaluation
   - prolog by unification?
   - or make it functional - I think the latter!
*)

(* 
  add import clause!
   - develop a module theory?
  import(filename).


  grammar: 
    definitions ::= definition [ definitions ]
    definition ::= name [ '(' [ args ] ')' ] [ ':-' body ]
    name ::= low_letter low_letters*
    var ::= cap_letter any_letter*
    args ::= var [',' args]
    body ::= clause [ `.' | `,' body ] 
    single_arg ::= name | var | clause | "term"
    clause ::= name '(' app_args  ')'
    app_args ::= single_arg [`,` app_args ]

See Isabelle cookbook for writing parsers 
 http://www.google.co.uk/url?sa=t&rct=j&q=&esrc=s&source=web&cd=1&ved=0CDEQFjAA&url=http%3A%2F%2Fwww4.in.tum.de%2F~urbanc%2Fcgi-bin%2Frepos.cgi%2Fisabelle-cookbook%2Fraw-file%2Ftip%2Fprogtutorial.pdf&ei=ZtE-U6T3BqWd7Qa2r4CwDA&usg=AFQjCNF41wL6W27p2pJ2IC_8VNg2cOr0Eg&sig2=xCIzds36ZNkQNN3RkhmSrg&bvm=bv.64125504,d.ZGU

TO DO:
  - support propositional logic?
  - support quantification?
  - support brackets in logic?
*)

(*
 examples 

 Global(X,Y,Z).

 test() :- test(A,B) , test2(B,C).
 
 single_pointl() :- shape("ex x. ?P"), has_term("x=?y","?P").
 single_pointr() :- shape("ex x. ?P"), has_term("?y=x","?P").

 single_point() :- single_pointl() , test().
 single_point() :- single_pointr() , test().
or
 single_point() :- (single_pointr() \/ single_pointl()) & test.



*)


end (* struct *)
