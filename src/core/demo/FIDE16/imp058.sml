local 
open ListUtilities in
val ¶_not_binding_thm = tac_proof(([],¬µ p:BOOL · (¶ x:'a· p) = p®), basic_prove_tac[]);
val µ_not_binding_thm = tac_proof(([],¬µ p:BOOL · (µ x:'a· p) = p®),basic_prove_tac[]);

local
	val tc = simple_eq_match_conv1 ¶_not_binding_thm;
in
val rec redundant_simple_¶_conv: CONV = (fn tm =>
let	val (exs,bdy) = strip_simple_¶ tm;
	val bdy_frees = frees bdy;
	fun aux [] = false
	| aux (x :: rest) = (
		(present (op =$) x rest) orelse not(present (op =$) x bdy_frees)
		orelse aux rest
	);
	fun aux1 [] tm = fail "redundant_simple_¶_conv" 0 []
	| aux1 (x :: rest) tm = (
		if (present (op =$) x rest) orelse not(present (op =$) x bdy_frees)
		then (tc THEN_TRY_C (aux1 rest)) tm
		else SIMPLE_BINDER_C (aux1 rest) tm
	);
in
	if aux exs
	then aux1 exs tm
	else fail "redundant_simple_¶_conv" 0 []
end);
end;
local
	val tc = simple_eq_match_conv1 µ_not_binding_thm;
in
val rec redundant_simple_µ_conv: CONV = (fn tm =>
let	val (exs,bdy) = strip_simple_µ tm;
	val bdy_frees = frees bdy;
	fun aux [] = false
	| aux (x :: rest) = (
		(present (op =$) x rest) orelse not(present (op =$) x bdy_frees)
		orelse (aux rest)
	);
	fun aux1 [] tm = fail "redundant_simple_µ_conv" 0 []
	| aux1 (x :: rest) tm = (
		if (present (op =$) x rest) orelse not(present (op =$) x bdy_frees)
		then (tc THEN_TRY_C (aux1 rest)) tm
		else SIMPLE_BINDER_C (aux1 rest) tm
	);
in
	if aux exs
	then aux1 exs tm
	else fail "redundant_simple_µ_conv" 0 []
end);
end;

end; (* end of local open *)

val strip_± = ±_tac;
val all_µ_uncurry = conv_tac all_µ_uncurry_conv;
val all_¶_uncurry = conv_tac all_¶_uncurry_conv;
val redundant_simple_¶ = conv_tac redundant_simple_¶_conv;
val redundant_simple_µ = conv_tac redundant_simple_µ_conv;
val simple_¶_± = conv_tac simple_¶_±_conv;
val simple_µ_± = conv_tac µ_±_conv;
val simple_¶_equation = conv_tac simple_¶_equation_conv; 

