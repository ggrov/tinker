theory rodin_main

imports Main
begin   
ML_file "../../debug_handler.ML"  
ML_file "../../interface/text_socket.ML"

ML_file "./interface/rodin_socket.ml"
ML_file "./interface/raw_source.ML"
ML_file "./interface/json.ML"
ML_file "./interface/io.ML"
ML_file "./interface/json_io.ML"
ML_file "./interface/interface.ML"

ML{*
 val k=Json.of_string "{\"\":\"\"}" 
val a=Rodin.buildCommand "a" [("k1","v1"),("a","b")];    
val b=Rodin.getParamKeys a;    
val b2=Rodin.getParamValues a; 
val c=Rodin.toJsonStr ("a",[]);
(* Connect to Rodin, and return the socket *)    
 val instance= Rodin.connect(1991);     
Rodin.toRodin instance ("GET_OPEN_DESCENDANTS_NUM",[]);      
 val read=Rodin.receivestr instance ; 
Rodin.toRodin instance ("NAME_OPEN_NODES", [("1","G1"),("2","G2"),("3","G3")]) ;      
  
val cmd=Rodin.fromRodin instance;   
val values= Rodin.getParamValues cmd;         
Rodin.close instance; 
*}   

end 
