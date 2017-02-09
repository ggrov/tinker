val tinkerhome = OS.FileSys.getDir() ^ "/psgraph";
use_file (tinkerhome ^ "/src/core/demo/TACAS16/tacas_setup");


val g : GOAL = 
 ([],
   ¬(µ (x, r) · ((¶ x0 · x0 > (x:î)) ± (µ (y,z)· ¶ y0· y0 < (y:î)))) ± 
    (¶ (m, r) · (m = (2 : î) ± (m + m = m * m)))®);

 val t = PSGraph.read_json_file NONE (pspath ^"simple_quantifier_tac.psgraph") |>   PSGraph.set_goaltype_data data; 

 set_goal g;
 apply_ps t;

 top_goal_state() |> print_goal_state;

 drop_main_goal();
 TextSocket.safe_close();
