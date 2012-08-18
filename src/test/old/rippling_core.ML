local 
val _ = use_thy "examples/N";

val thy = theory "N";
val ctxt = Context.Theory thy;
val ctxt = ProofContext.init thy; 

val IH = (Const("HOL.Trueprop", Type("fun", [Type("HOL.bool", []), Type("prop", [])]))) $
 (((Const("HOL.eq", Type("fun", [Type("N.N", []), Type("fun", [Type("N.N", []), Type("HOL.bool", [])])]))) $
 (((Const("HOL.plus_class.plus", Type("fun", [Type("N.N", []), Type("fun", [Type("N.N", []), Type("N.N", [])])]))) $
 (((Const("HOL.times_class.times", Type("fun", [Type("N.N", []), Type("fun", [Type("N.N", []), Type("N.N", [])])]))) $
 (Free("o", Type("N.N", [])))) $
 (Var( ("t",0), Type("N.N", []))))) $
 (((Const("HOL.times_class.times", Type("fun", [Type("N.N", []), Type("fun", [Type("N.N", []), Type("N.N", [])])]))) $
 (Var( ("u",0), Type("N.N", [])))) $
 (Var( ("t",0), Type("N.N", [])))))) $
 (((Const("HOL.times_class.times", Type("fun", [Type("N.N", []), Type("fun", [Type("N.N", []), Type("N.N", [])])]))) $
 (((Const("HOL.plus_class.plus", Type("fun", [Type("N.N", []), Type("fun", [Type("N.N", []), Type("N.N", [])])]))) $
 (Free("o", Type("N.N", [])))) $
 (Var( ("u",0), Type("N.N", []))))) $
 (Var( ("t",0), Type("N.N", [])))));

val _ = Trm.print ctxt IH;

val g0 = (Const("HOL.Trueprop", Type("fun", [Type("HOL.bool", []), Type("prop", [])]))) $
 (((Const("HOL.eq", Type("fun", [Type("N.N", []), Type("fun", [Type("N.N", []), Type("HOL.bool", [])])]))) $
 (((Const("HOL.plus_class.plus", Type("fun", [Type("N.N", []), Type("fun", [Type("N.N", []), Type("N.N", [])])]))) $
 (((Const("HOL.times_class.times", Type("fun", [Type("N.N", []), Type("fun", [Type("N.N", []), Type("N.N", [])])]))) $
 ((Const("N.N.suc", Type("fun", [Type("N.N", []), Type("N.N", [])]))) $
 (Free("o", Type("N.N", []))))) $
 (Free("r", Type("N.N", []))))) $
 (((Const("HOL.times_class.times", Type("fun", [Type("N.N", []), Type("fun", [Type("N.N", []), Type("N.N", [])])]))) $
 (Free("s", Type("N.N", [])))) $
 (Free("r", Type("N.N", [])))))) $
 (((Const("HOL.times_class.times", Type("fun", [Type("N.N", []), Type("fun", [Type("N.N", []), Type("N.N", [])])]))) $
 (((Const("HOL.plus_class.plus", Type("fun", [Type("N.N", []), Type("fun", [Type("N.N", []), Type("N.N", [])])]))) $
 ((Const("N.N.suc", Type("fun", [Type("N.N", []), Type("N.N", [])]))) $
 (Free("o", Type("N.N", []))))) $
 (Free("s", Type("N.N", []))))) $
 (Free("r", Type("N.N", [])))));

val g1 = (Const("HOL.Trueprop", Type("fun", [Type("HOL.bool", []), Type("prop", [])]))) $
 (((Const("HOL.eq", Type("fun", [Type("N.N", []), Type("fun", [Type("N.N", []), Type("HOL.bool", [])])]))) $
 (((Const("HOL.plus_class.plus", Type("fun", [Type("N.N", []), Type("fun", [Type("N.N", []), Type("N.N", [])])]))) $
 (((Const("HOL.plus_class.plus", Type("fun", [Type("N.N", []), Type("fun", [Type("N.N", []), Type("N.N", [])])]))) $
 (Free("r", Type("N.N", [])))) $
 (((Const("HOL.times_class.times", Type("fun", [Type("N.N", []), Type("fun", [Type("N.N", []), Type("N.N", [])])]))) $
 (Free("o", Type("N.N", [])))) $
 (Free("r", Type("N.N", [])))))) $
 (((Const("HOL.times_class.times", Type("fun", [Type("N.N", []), Type("fun", [Type("N.N", []), Type("N.N", [])])]))) $
 (Free("s", Type("N.N", [])))) $
 (Free("r", Type("N.N", [])))))) $
 (((Const("HOL.times_class.times", Type("fun", [Type("N.N", []), Type("fun", [Type("N.N", []), Type("N.N", [])])]))) $
 (((Const("HOL.plus_class.plus", Type("fun", [Type("N.N", []), Type("fun", [Type("N.N", []), Type("N.N", [])])]))) $
 ((Const("N.N.suc", Type("fun", [Type("N.N", []), Type("N.N", [])]))) $
 (Free("o", Type("N.N", []))))) $
 (Free("s", Type("N.N", []))))) $
 (Free("r", Type("N.N", [])))));


val g2 = (Const("HOL.Trueprop", Type("fun", [Type("HOL.bool", []), Type("prop", [])]))) $
 (((Const("HOL.eq", Type("fun", [Type("N.N", []), Type("fun", [Type("N.N", []), Type("HOL.bool", [])])]))) $
 (((Const("HOL.plus_class.plus", Type("fun", [Type("N.N", []), Type("fun", [Type("N.N", []), Type("N.N", [])])]))) $
 (((Const("HOL.plus_class.plus", Type("fun", [Type("N.N", []), Type("fun", [Type("N.N", []), Type("N.N", [])])]))) $
 (Free("r", Type("N.N", [])))) $
 (((Const("HOL.times_class.times", Type("fun", [Type("N.N", []), Type("fun", [Type("N.N", []), Type("N.N", [])])]))) $
 (Free("o", Type("N.N", [])))) $
 (Free("r", Type("N.N", [])))))) $
 (((Const("HOL.times_class.times", Type("fun", [Type("N.N", []), Type("fun", [Type("N.N", []), Type("N.N", [])])]))) $
 (Free("s", Type("N.N", [])))) $
 (Free("r", Type("N.N", [])))))) $
 (((Const("HOL.times_class.times", Type("fun", [Type("N.N", []), Type("fun", [Type("N.N", []), Type("N.N", [])])]))) $
 ((Const("N.N.suc", Type("fun", [Type("N.N", []), Type("N.N", [])]))) $
 (((Const("HOL.plus_class.plus", Type("fun", [Type("N.N", []), Type("fun", [Type("N.N", []), Type("N.N", [])])]))) $
 (Free("o", Type("N.N", [])))) $
 (Free("s", Type("N.N", [])))))) $
 (Free("r", Type("N.N", [])))));

val g3 = (Const("HOL.Trueprop", Type("fun", [Type("HOL.bool", []), Type("prop", [])]))) $
 (((Const("HOL.eq", Type("fun", [Type("N.N", []), Type("fun", [Type("N.N", []), Type("HOL.bool", [])])]))) $
 (((Const("HOL.plus_class.plus", Type("fun", [Type("N.N", []), Type("fun", [Type("N.N", []), Type("N.N", [])])]))) $
 (((Const("HOL.plus_class.plus", Type("fun", [Type("N.N", []), Type("fun", [Type("N.N", []), Type("N.N", [])])]))) $
 (Free("r", Type("N.N", [])))) $
 (((Const("HOL.times_class.times", Type("fun", [Type("N.N", []), Type("fun", [Type("N.N", []), Type("N.N", [])])]))) $
 (Free("o", Type("N.N", [])))) $
 (Free("r", Type("N.N", [])))))) $
 (((Const("HOL.times_class.times", Type("fun", [Type("N.N", []), Type("fun", [Type("N.N", []), Type("N.N", [])])]))) $
 (Free("s", Type("N.N", [])))) $
 (Free("r", Type("N.N", [])))))) $
 (((Const("HOL.plus_class.plus", Type("fun", [Type("N.N", []), Type("fun", [Type("N.N", []), Type("N.N", [])])]))) $
 (Free("r", Type("N.N", [])))) $
 (((Const("HOL.times_class.times", Type("fun", [Type("N.N", []), Type("fun", [Type("N.N", []), Type("N.N", [])])]))) $
 (((Const("HOL.plus_class.plus", Type("fun", [Type("N.N", []), Type("fun", [Type("N.N", []), Type("N.N", [])])]))) $
 (Free("o", Type("N.N", [])))) $
 (Free("s", Type("N.N", []))))) $
 (Free("r", Type("N.N", []))))));


val ienv = (InstEnv.init (theory "N"));
val ectxt = Embed.Ectxt.init ienv ParamRGraph.empty;

val skel = IH;
val target = g0;

val e0s = (Embed.embed ectxt skel target)
            |> Seq.list_of;

val [e] = e0s;
val m = RippleMeasure.init_measure e;

val ms = (Embed.embed ectxt skel target)
           |> Seq.list_of
           |> maps (fn e => map (pair e) (RippleMeasure.init_measure e));

val [s0] = RippleSkel.init {ectxt=ectxt, skelterm=IH, 
                 skelname="IH", target=g0};

val _ = RippleSkel.print s0;

val [s2] = RippleSkel.init {ectxt=ectxt, skelterm=IH, 
                 skelname="IH", target=g2};

val _ = RippleSkel.print s2;

val [s3] = RippleSkel.init {ectxt=ectxt, skelterm=IH, 
                         skelname="IH", target=g3};

val _ = RippleSkel.print s3;

in
val _ = writeln "Test Completed: test/rippling_core.ML";
end;


(* 
raise ERROR "STOP";
RippleSkel.mk_next ectxt newgoalterm s
*)
