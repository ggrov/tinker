
  structure V = struct open SStrName; val default_name = mk "Va"; end (* vertices *)
  structure E = struct open SStrName; val default_name = mk "Ea"; end (* edges *)
  structure G = struct open SStrName; val default_name = mk "Ga"; end;(* goal type *)

  structure SStrTab = NameTable(structure Dom = SStrName)
  structure VTab = SStrTab
  structure ETab = SStrTab

  structure SStrFn  = NameFunction(structure Dom = SStrName; structure Cod = SStrName)
  structure EVFn = SStrFn



