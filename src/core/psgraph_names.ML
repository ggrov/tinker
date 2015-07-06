  (* name of class *)
  structure C = 
   struct 
     open SStrName;
     val default_name = mk "Ca"; 
   end;

  (* name of class feature *)
  structure F = 
   struct 
     open SStrName;
     val default_name = mk "Fa"; 
   end;
 
   (* name of links *)
  structure L = 
   struct 
     open SStrName;
     val default_name = mk "La"; 
   end; 

  (* name of goal type *)
  structure G = 
   struct 
     open SStrName;
     val default_name = mk "Ga"; 
   end;

