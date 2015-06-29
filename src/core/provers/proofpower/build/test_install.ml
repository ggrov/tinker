
structure test1 = StrName; (*isalib is OK*)
structure test2 = SimpleLexer;(*quanto is OK*)
set_goal;(*proof power is OK*)

(*Theor Hierarchy is OK*)
get_theory_names();
get_current_pc();
