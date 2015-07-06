theory tinker_isabelle                                 
imports       
  "./setup_isabelle"    
begin

(* read and load a psgraph created by gui *)

ML{*
  val ps = PSGraph.read_json_file (path ^"demo.psgraph");
*}

ML{*
  val guiPath = "/home/pierre/Documents/HW/Tinker/tinkerGit/tinker/src/tinkerGUI/release/";
  local open CInterface in
  val get = get_sym (guiPath^"guiLauncher.so");
  val opengui = call2 (get "openGUI") (STRING,STRING) INT;
  val closegui = call1 (get "closeGUI") (INT) INT;
  end
*}

ML{*-
  val pid = opengui(guiPath,"0.3");
*}

ML{*-
  closegui(pid);
*}

ML{* -
  TextSocket.safe_close();
*}   

ML{*- 
val thm = Tinker.start_ieval @{context} ps [] @{prop "P  \<longrightarrow>  (P \<and>  P \<and> (Q \<longrightarrow> Q))"} (* prove the goal *)
          |> EData.get_pplan |> IsaProver.get_goal_thm(* get the theorem *)
*}


