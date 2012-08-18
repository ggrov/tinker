local 

val _ = use_thy "benchmarks/CaseAnalysis_L";
val thy = theory "CaseAnalysis_L";

val ectxt = Ectxt.init (InstEnv.init thy) ParamRGraph.empty;

val s2 = (((Const("CaseAnalysis_L.zip", Type("fun", [Type("List.list", [TFree("'a", ["HOL.type"])]), Type("fun", [Type("List.list", [TFree("'a", ["HOL.type"])]), Type("List.list", [Type("*", [TFree("'a", ["HOL.type"]), TFree("'a", ["HOL.type"])])])])]))) $
 (Const("List.list.Nil", Type("List.list", [TFree("'a", ["HOL.type"])])))) $
 (Free("yt", Type("List.list", [TFree("'a", ["HOL.type"])]))));

val t2 = ((((Const("List.list.list_case", Type("fun", [Type("List.list", [Type("*", [TFree("'a", ["HOL.type"]), TFree("'a", ["HOL.type"])])]), Type("fun", [Type("fun", [TFree("'a", ["HOL.type"]), Type("fun", [Type("List.list", [TFree("'a", ["HOL.type"])]), Type("List.list", [Type("*", [TFree("'a", ["HOL.type"]), TFree("'a", ["HOL.type"])])])])]), Type("fun", [Type("List.list", [TFree("'a", ["HOL.type"])]), Type("List.list", [Type("*", [TFree("'a", ["HOL.type"]), TFree("'a", ["HOL.type"])])])])])]))) $
 (Const("List.list.Nil", Type("List.list", [Type("*", [TFree("'a", ["HOL.type"]), TFree("'a", ["HOL.type"])])])))) $
 (Abs("z",TFree("'a", ["HOL.type"]), 
  Abs("zs",Type("List.list", [TFree("'a", ["HOL.type"])]), 
  ((Const("List.list.Cons", Type("fun", [Type("*", [TFree("'a", ["HOL.type"]), TFree("'a", ["HOL.type"])]), Type("fun", [Type("List.list", [Type("*", [TFree("'a", ["HOL.type"]), TFree("'a", ["HOL.type"])])]), Type("List.list", [Type("*", [TFree("'a", ["HOL.type"]), TFree("'a", ["HOL.type"])])])])]))) $
 (((Const("Product_Type.Pair", Type("fun", [TFree("'a", ["HOL.type"]), Type("fun", [TFree("'a", ["HOL.type"]), Type("*", [TFree("'a", ["HOL.type"]), TFree("'a", ["HOL.type"])])])]))) $
 (Bound(1))) $
 (Free("a", TFree("'a", ["HOL.type"]))))) $
 (((Const("CaseAnalysis_L.zip", Type("fun", [Type("List.list", [TFree("'a", ["HOL.type"])]), Type("fun", [Type("List.list", [TFree("'a", ["HOL.type"])]), Type("List.list", [Type("*", [TFree("'a", ["HOL.type"]), TFree("'a", ["HOL.type"])])])])]))) $
 (Bound(0))) $
 (Free("yt", Type("List.list", [TFree("'a", ["HOL.type"])])))))))) $
 (Const("List.list.Nil", Type("List.list", [TFree("'a", ["HOL.type"])]))));

val ctxt = ProofContext.init thy;

val _ = Trm.print ctxt s2;
val _ = Trm.print ctxt t2;

val e = hd (Seq.list_of (DB_Embed.embed ectxt s2 t2));

val _ = map Embed.print (Seq.list_of (DB_Embed.embed ectxt s2 t2));

in
val _ = writeln "Test Completed: test/embed.ML";
end;


(* 
PolyML.exception_trace (fn () =>  
map Embed.print (Seq.list_of (DB_Embed.embed ectxt s2 t2))
);

PolyML.Debug.clearIn "DB_Embed.embed";
 
PolyML.exception_trace (fn () =>  
Seq.list_of (DB_Embed.embed ectxt s2 t2)
);

PolyML.Debug.breakIn "DB_Ectxt.lookup_bnd_wf";
PolyML.Debug.up();
PolyML.Debug.down();
PolyML.Debug.variables();
PolyML.Debug.continue();
PolyML.Debug.clearIn "DB_Ectxt.lookup_bnd_wf";
PolyML.Debug.breakIn "DB_Embed.embed_into_some_subpos";
PolyML.Debug.breakIn "DB_Embed.solve_bnd_embedding_agenda";
PolyML.Debug.continue();

PolyML.Debug.trace true;

open DB_Embed;

val (SOME ((n,(wfn,t)), a2)) = Em.NTab.pull_elem (get_agenda e);
val wf = Wf.NTab.get (get_wfs e) wfn;

Embed.app_embeddings 
  ectxt
  (Term.strip_comb (Pattern.eta_long [] s))
  (Term.strip_comb (Pattern.eta_long [] t));

*)
